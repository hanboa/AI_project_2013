AI_project_2013
===============

First, 
the directory of dataset on Github is empty and remind you to download the dataset from the link:

https://www.dropbox.com/sh/kf2j9u2p8g47tzp/W1831jbHUH

and then replies the directory, such as ?queries? and ?dictionary_dataset?

Second, how to execute:

1. Go to the directory of ?iSystem?

2. Type the command in your Matlab console
	query();
or
	query( number_query_image, number_retrieved_image)

NOTE: make sure the query image?s number is enough in the directory of ?queries?

3. You will get the result (by default): 
	one query image from ?queries? and 10 similar images from ?dictionary_dataset?



TO BE IMPROVED:
1. random patch selection (both in query and in database)
2. projection



NOTE:
Database has been indexed as ?database.mat? by the function ?databaseIndexing.m?