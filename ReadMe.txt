
—————————————————————————————————————————————————————
1. data
—————————————————————————————————————————————————————

For each dataset (a collection of graphs), the adjacency matrix (A) and the label per node 
are necessary for each graph. If the initial/independent layout (X) is not given, it can be set randomly. 

•	Princeton Shape Benchmark (19 shapes)				
•	Stanford ShapeNetCore (3 shapes: airplane, motorcycle, rocket)
•	FAUST dataset (10 persons * 10 poses )				
•	Floor plan (9 graphs manually created)
•	Stanford Scene database (8 graphs manually created)
•	Food network (4 countries)

—————————————————————————————————————————————————————  
2. func_JointMap: main functions of the algorithm
—————————————————————————————————————————————————————
step 0: preprocessing.m
	Given the adjacency matrix and labels, compute 
	•	the Laplacians (L)
	•	the correspondence matrices(B and D)
	•	the distance matrix (d) to be preserved, 
	•	the penalty coefficients (\mu, \lambda)

step 1: spectral initialization - get_embedding.m
	Find the spectral initialization: the solution to optimize the first two energy terms 

step 2: stress_majorization.m
	apply the stress majorization algorithm to find the joint layout


—————————————————————————————————————————————————————
3. func: not important functions
—————————————————————————————————————————————————————
set_parameters.m
	It keeps the parameters (c1, c2, c3, c4) consistent with the paper.

generateLayout.m
	Simply the combination of preprocessing.m + get_embedding.m + stress_majorization.m

—————————————————————————————————————————————————————
4. test
—————————————————————————————————————————————————————
testLayout.m 

	The main test script: generate the joint layout for the following dataset: 
	•	6 shapes from PSB
	•	3 shapes from ShapeNetCore
	•	other: scene, floorplan, food network

	For the above datasets, just set the model_name and run the script, it will set the parameters consistent with the paper. 
	For other datasets, load the data (with adjacency matrix, label and initial layout) and set the parameters.

testFAUST.m
	Use the FAUST dataset to compare the joint layout and the MDS layout

testGraphErr_PSB.m, testGraphErr_SNC.m
	visualize the graph error (two scripts are almost the same but with different parameters)