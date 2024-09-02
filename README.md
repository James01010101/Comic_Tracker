


Quick common things to remember:
* Views inheret from the view that called them. So if I set some setitngs in a view and then call another one those settings will also be applied to the next view.


Here are some common errors and how to fix them:
Navagation title overlapping content.
If i used this in my main view
.onAppear(perform: {
  UICollectionView.appearance().contentInset.top = -35
})
All subsequent views will inheret this and will push everything up higher than it should be.


When making changes to the save files and datastructures there is 3 main cases i need to deal with.

1. Adding new data fields
In this case i just add the new field into the data structure
In its decode function (load) i decode it if present and give it a default value, since it wont exist the first time it will be loaded with a default value.
In its encode value i just write it to the file as i would normally.
Then after one load and ssave all structures should have this as a default variable i can use. I will need to manually go through and edit these myself to add the relevant data to them.

2. Remove old data fields
Remove this field from the decode (load) and the encode (save) so you dont write it to a file, so the next file you save does not contain that data anymore.
Then you wont load the data anymore and wont save it either so it will be completely gone.
Need to make sure I really dont want this data because i wont be able to get it back.

3. Updating / converting old fields into new structures
In this case i first need to create a new field in my structure to hold my new format of variable.
BUT KEEP THE OLD VARIABLE FOR NOW.
write a function that once ive read in the origional data into its normal format makes a copy and formats it into the new format i want.
then write the encode functions for my new data so i can save it to a file.
Now after one load and convert and save i can check that the data was correctly written to the file in the new format that i want. Ill need to manually check that this works.
Once im happy and i know its formatted correctly and being written to the file as i want. I can then remove the conversion logic and add in a decode function to be able to read  in the formatted data.
Once this is working i then know that it is seperated from the origional data and is being loaded and written by itself, Then once im sure i can delete the old fields so they aren't read or saved anymore.
