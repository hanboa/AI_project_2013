AI_project_2013
===============

How to execute:

1. Go to the directory 'iSystem'

2. Type the following command in your Matlab console:
	query();
or
	query( number_query_image, number_retrieved_image)

NOTE: The value of 'number_query_image' should be smaller than the total number of images in the directory 'queries'!

3. You will get the result (by default): 
	one query image from 'queries' and 10 similar images from 'dataset'



TO BE IMPROVED:
1. random patch selection (both in query and in database)
2. projection



NOTE:
Database has been indexed as database.mat by the function databaseIndexing.m
