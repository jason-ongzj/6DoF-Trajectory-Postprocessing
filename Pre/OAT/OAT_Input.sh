#!/bin/bash

# Run ./OAT_Input.sh <input_var>
# E.g. ./OAT_Input.sh OAT_Variables_3Sigma.txt
# Note: Input script always takes reference from input_nominal.tops file
#       since input_nominal contains default configuration.

vehicle="Dorado_1S"
output_file="OAT_Input_$vehicle.gabc"
numColumns=$(grep "\S" $1 | tail -n +2 | wc -l)
lastPhase="4"
burnPhase="3"
secondLastPhase="3"
input_file="./input - nominal.tops"

sed '1d' $1 >> OAT_Intermediate_Variables.txt
echo -e "\
<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>\n\
<Gabc checksum=\"a3990260103\">\n\
	<Version>2.0</Version>\n\
	<BatchModeNodes>\n\
		<Node>\n\
			<Id>Batch</Id>\n\
			<Name>OAT_Analysis</Name>\n\
			<Description></Description>\n\
			<IgnoreErrors>false</IgnoreErrors>\n\
			<Children>" >> $output_file

count=0
while read -r f1 f2 f3 f4 f5
do
		echo -e "\
				<Node>\n\
					<Id>Loop</Id>\n\
					<Name>"$f1"</Name>\n\
					<VariableName>"$f1"</VariableName>\n\
					<Mode>1</Mode>\n\
					<InitialValue>"$f2"</InitialValue>\n\
					<FinalValue>"$f4"</FinalValue>\n\
					<Steps>1</Steps>\n\
					<StepsSize>"$f3"</StepsSize>\n\
					<ValueList></ValueList>\n\
					<Children>\n\
						<Node>\n\
							<Id>Simulate</Id>\n\
							<Name>Simulate_"$count"</Name>\n\
							<Mode>3</Mode>\n\
							<CustomTops>true</CustomTops>\n\
							<InputTops>$input_file</InputTops>\n\
							<OutputStruct>./integ/simulation_OAT.struct</OutputStruct>\n\
							<OutputTxt>./integ/simulation_OAT.txt</OutputTxt>\n\
						</Node>\n\
						<Node>\n\
							<Id>Evaluate</Id>\n\
							<Name>Lat</Name>\n\
							<VariableName>Latitude</VariableName>\n\
							<Source>Simulation Struct</Source>\n\
							<CustomFile>true</CustomFile>\n\
							<FileName>./integ/simulation_OAT.struct</FileName>\n\
							<Category>Auxiliary Functions</Category>\n\
							<Phase>$lastPhase</Phase>\n\
							<NameOf>latitude~$vehicle#PCPF~Earth@Earth</NameOf>\n\
							<WhichValue>Last</WhichValue>\n\
							<Modifier>None</Modifier>\n\
						</Node>\n\
						<Node>\n\
							<Id>Evaluate</Id>\n\
							<Name>Long</Name>\n\
							<VariableName>Longitude</VariableName>\n\
							<Source>Simulation Struct</Source>\n\
							<CustomFile>true</CustomFile>\n\
							<FileName>./integ/simulation_OAT.struct</FileName>\n\
							<Category>Auxiliary Functions</Category>\n\
							<Phase>$lastPhase</Phase>\n\
							<NameOf>longitude~$vehicle#PCPF~Earth@Earth</NameOf>\n\
							<WhichValue>Last</WhichValue>\n\
							<Modifier>None</Modifier>\n\
						</Node>\n\
						<Node>\n\
							<Id>Evaluate</Id>\n\
							<Name>Alt</Name>\n\
							<VariableName>Max_Altitude</VariableName>\n\
							<Source>Simulation Struct</Source>\n\
							<CustomFile>true</CustomFile>\n\
							<FileName>./integ/simulation_OAT.struct</FileName>\n\
							<Category>Auxiliary Functions</Category>\n\
							<Phase>$lastPhase</Phase>\n\
							<NameOf>altitude~$vehicle@Earth</NameOf>\n\
							<WhichValue>Maximum</WhichValue>\n\
							<Modifier>None</Modifier>\n\
						</Node>\n\
						<Node>\n\
							<Id>Evaluate</Id>\n\
							<Name>Static_Margin</Name>\n\
							<VariableName>Static_Margin</VariableName>\n\
							<Source>Simulation Struct</Source>\n\
							<CustomFile>true</CustomFile>\n\
							<FileName>./integ/simulation_OAT.struct</FileName>\n\
							<Category>Auxiliary Functions</Category>\n\
							<Phase>3</Phase>\n\
							<NameOf>static_stability_x~$vehicle#B~$vehicle@$vehicle</NameOf>\n\
							<WhichValue>Last</WhichValue>\n\
							<Modifier>None</Modifier>\n\
						</Node>\n\
						<Node>\n\
							<Id>Evaluate</Id>\n\
							<Name>Roll_Rate_Phase3</Name>\n\
							<VariableName>Roll_Rate_Phase3</VariableName>\n\
							<Source>Simulation Struct</Source>\n\
							<CustomFile>true</CustomFile>\n\
							<FileName>./integ/simulation_OAT.struct</FileName>\n\
							<Category>Auxiliary Functions</Category>\n\
							<Phase>$burnPhase</Phase>\n\
							<NameOf>roll_rate~$vehicle#L~$vehicle:Earth</NameOf>\n\
							<WhichValue>Maximum</WhichValue>\n\
							<Modifier>Absolute</Modifier>\n\
						</Node>\n\
						<Node>\n\
							<Id>Evaluate</Id>\n\
							<Name>Mach</Name>\n\
							<VariableName>Mach</VariableName>\n\
							<Source>Simulation Struct</Source>\n\
							<CustomFile>true</CustomFile>\n\
							<FileName>./integ/simulation_OAT.struct</FileName>\n\
							<Category>Auxiliary Functions</Category>\n\
							<Phase>$burnPhase</Phase>\n\
							<NameOf>mach~$vehicle</NameOf>\n\
							<WhichValue>Maximum</WhichValue>\n\
							<Modifier>Absolute</Modifier>\n\
						</Node>\n\
						<Node>\n\
							<Id>Evaluate</Id>\n\
							<Name>Alt_P5</Name>\n\
							<VariableName>Alt_P5</VariableName>\n\
							<Source>Simulation Struct</Source>\n\
							<CustomFile>true</CustomFile>\n\
							<FileName>./integ/simulation_OAT.struct</FileName>\n\
							<Category>Auxiliary Functions</Category>\n\
							<Phase>$secondLastPhase</Phase>\n\
							<NameOf>altitude~$vehicle@Earth</NameOf>\n\
							<WhichValue>Maximum</WhichValue>\n\
							<Modifier>None</Modifier>\n\
						</Node>\n\
						<Node>\n\
							<Id>Save Values</Id>\n\
							<Name>Save_Values_"$count"</Name>\n\
							<FileName>./integ/OAT_Data_"$2"Sigma.txt</FileName>\n\
							<Mode>Append</Mode>\n\
							<Type>Table</Type>\n\
							<Description></Description>\n\
							<NumColumns>7</NumColumns>\n\
							<NumHeaders>1</NumHeaders>\n\
							<Table>\n\
								<Column>\n\
									<Header>\n\
										<Name>Lat</Name>\n\
									</Header>\n\
									<Name>Latitude</Name>\n\
								</Column>\n\
								<Column>\n\
									<Header>\n\
										<Name>Long</Name>\n\
									</Header>\n\
									<Name>Longitude</Name>\n\
								</Column>\n\
								<Column>\n\
									<Header>\n\
										<Name>Alt</Name>\n\
									</Header>\n\
									<Name>Max_Altitude</Name>\n\
								</Column>\n\
								<Column>\n\
									<Header>\n\
										<Name>Static_Margin</Name>\n\
									</Header>\n\
									<Name>Static_Margin</Name>\n\
								</Column>\n\
								<Column>\n\
									<Header>\n\
										<Name>Roll_Rate_Phase3</Name>\n\
									</Header>\n\
									<Name>Roll_Rate_Phase3</Name>\n\
								</Column>\n\
								<Column>\n\
									<Header>\n\
										<Name>Mach</Name>\n\
									</Header>\n\
									<Name>Mach</Name>\n\
								</Column>\n\
								<Column>\n\
									<Header>\n\
										<Name>Alt_P5</Name>\n\
									</Header>\n\
									<Name>Alt_P5</Name>\n\
								</Column>\n\
							</Table>\n\
						</Node>\n\
					</Children>\n\
				</Node>\n\
				<Node>\n\
					<Id>External</Id>\n\
					<Name>External_"$count"</Name>\n\
					<Template>Custom</Template>\n\
					<FileName>./scripts/Windows/OAT_"$2"Sigma.bat</FileName>\n\
					<CommandLine></CommandLine>\n\
				</Node>" >> $output_file
		count=$((count+1))
done < OAT_Intermediate_Variables.txt
rm OAT_Intermediate_Variables.txt

echo -e "\
			</Children>\n\
		</Node>\n\
	</BatchModeNodes>\n\
</Gabc>\n\
" >> $output_file
