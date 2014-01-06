function output = getCategory( name ),
% input: labeled file name
str = name(1 : end-5);
islet = false(size(str)) ;
islet(regexp(str,'[A-Za-z]')) = true ;
output = str(islet);

end