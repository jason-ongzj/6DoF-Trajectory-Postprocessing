#!/bin/bash

if [ -z "$(ls -A Postprocessing/Data/Nominal)" ]; then
	echo "Nominal output folder is empty."
else
	echo "Not empty, clearing nominal data folder."
	rm Postprocessing/Data/Nominal/Ellipse*
fi

if [ -z "$(ls -A Postprocessing/Output)" ]; then
	echo "KML output folder is empty."
else
	echo "Not empty, clearing KML output folder."
	rm Postprocessing/Output/*.kml
fi