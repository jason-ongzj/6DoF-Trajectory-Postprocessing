#!/bin/bash

# 1st argument - input filename, 2nd argument - No. of iterations
# Eg. Run ./Monte_Carlo_Input.sh Monte_Carlo_Variables_MAD.txt 1000

# Change variables as required based on the setup in ASTOS
# Latitude, longitude, apogee and roll rate values are collected along with other MC inputs
output_file="Monte_Carlo_Input_$2.gabc"
vehicle="Dorado_1S"
nLines=$(grep "\S" $1 | tail -n +2 | wc -l)
numColumns=$(($nLines + 4))
lastPhase="4"
burnPhase="3"

sed '1d' $1 >> Monte_Carlo_Input_Intermediate.txt
echo -e "\
<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>
<Gabc checksum=\"a4198783754\">
	<Version>2.0</Version>
	<BatchModeNodes>
		<Node>
			<Id>Batch</Id>
			<Name>Dispersion_analysis</Name>
			<Description></Description>
			<IgnoreErrors>false</IgnoreErrors>
			<Children>
				<Node>
					<Id>Random</Id>
					<Name>Random_1</Name>
					<NumberOfLoops>$2</NumberOfLoops>
					<ItemList>" >> $output_file

while read -r f1 f2 f3 f4 f5 f6 f7
do
  echo -e "\
						<Item>\n\
						  	<VariableName>$f1</VariableName>\n\
						  	<Distribution>$f2</Distribution>\n\
						  	<LowerBound>$f3</LowerBound>\n\
						  	<UpperBound>$f4</UpperBound>\n\
						  	<Mean>$f5</Mean>\n\
						  	<RandomTable>$f6</RandomTable>\n\
						</Item>" >> $output_file
done < Monte_Carlo_Input_Intermediate.txt

echo -e "\
					</ItemList>
					<Children>
						<Node>
							<Id>Simulate</Id>
							<Name>Simulate</Name>
							<Mode>3</Mode>
							<CustomTops>true</CustomTops>
							<InputTops>./input - nominal.tops</InputTops>
							<OutputStruct>./integ/simulation_MC.struct</OutputStruct>
							<OutputTxt>./integ/simulation_MC.txt</OutputTxt>
						</Node>
						<Node>
							<Id>Evaluate</Id>
							<Name>Lat</Name>
							<VariableName>Latitude</VariableName>
							<Source>Simulation Struct</Source>
							<CustomFile>true</CustomFile>
							<FileName>./integ/simulation_MC.struct</FileName>
							<Category>Auxiliary Functions</Category>
							<Phase>$lastPhase</Phase>
							<NameOf>latitude~$vehicle#PCPF~Earth@Earth</NameOf>
							<WhichValue>Last</WhichValue>
							<Modifier>None</Modifier>
						</Node>
						<Node>
							<Id>Evaluate</Id>
							<Name>Long</Name>
							<VariableName>Longitude</VariableName>
							<Source>Simulation Struct</Source>
							<CustomFile>true</CustomFile>
							<FileName>./integ/simulation_MC.struct</FileName>
							<Category>Auxiliary Functions</Category>
							<Phase>$lastPhase</Phase>
							<NameOf>longitude~$vehicle#PCPF~Earth@Earth</NameOf>
							<WhichValue>Last</WhichValue>
							<Modifier>None</Modifier>
						</Node>
						<Node>
							<Id>Evaluate</Id>
							<Name>Alt</Name>
							<VariableName>Max_Altitude</VariableName>
							<Source>Simulation Struct</Source>
							<CustomFile>true</CustomFile>
							<FileName>./integ/simulation_MC.struct</FileName>
							<Category>Auxiliary Functions</Category>
							<Phase>$lastPhase</Phase>
							<NameOf>altitude~$vehicle@Earth</NameOf>
							<WhichValue>Maximum</WhichValue>
							<Modifier>None</Modifier>
						</Node>
						<Node>
							<Id>Evaluate</Id>
							<Name>Roll_Rate_Phase3</Name>
							<VariableName>Roll_Rate_Phase3</VariableName>
							<Source>Simulation Struct</Source>
							<CustomFile>true</CustomFile>
							<FileName>./integ/simulation_MC.struct</FileName>
							<Category>Auxiliary Functions</Category>
							<Phase>$burnPhase</Phase>
							<NameOf>roll_rate~$vehicle#L~$vehicle:Earth</NameOf>
							<WhichValue>Maximum</WhichValue>
							<Modifier>Absolute</Modifier>
						</Node>
						<Node>
							<Id>Save Values</Id>
							<Name>Save_Values</Name>
							<FileName>./integ/MC_Results.txt</FileName>
							<Mode>Append</Mode>
							<Type>Table</Type>
							<Description></Description>
							<NumColumns>$numColumns</NumColumns>
							<NumHeaders>2</NumHeaders>
							<Table>
								<Column>
									<Header>
										<Name>Long</Name>
									</Header>
									<Header>
										<Name>degree</Name>
									</Header>
									<Name>Longitude</Name>
								</Column>
								<Column>
									<Header>
										<Name>Lat</Name>
									</Header>
									<Header>
										<Name>degree</Name>
									</Header>
									<Name>Latitude</Name>
								</Column>
								<Column>
									<Header>
										<Name>Max_Alt</Name>
									</Header>
									<Header>
										<Name>kilo-meter</Name>
									</Header>
									<Name>Max_Altitude</Name>
								</Column>
								<Column>
									<Header>
										<Name>Roll_Rate</Name>
									</Header>
									<Header>
										<Name>deg-per-sec</Name>
									</Header>
									<Name>Roll_Rate_Phase3</Name>
								</Column> " >> $output_file

while read -r f1 f2 f3 f4 f5 f6 f7
do
  echo -e "\
								<Column>
									<Header>
										<Name>$f1</Name>
									</Header>
									<Header>
										<Name>$f7</Name>
									</Header>
									<Name>$f1</Name>
								</Column>" >> $output_file
done < Monte_Carlo_Input_Intermediate.txt

echo -e "\
							</Table>
						</Node>
					</Children>
				</Node>
			</Children>
		</Node>
	</BatchModeNodes>
</Gabc>" >> $output_file

rm Monte_Carlo_Input_Intermediate.txt
