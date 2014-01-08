function cb = compactbit(b)
% Create compacted bit-string for an image
% from the bit-strings of the patches of that image.
%
% b = bits array
% cb = compacted string of bits (using words of 'word' bits)

[nSamples nbits] = size(b);
oneCount = zeros(1, nbits);
bavg = zeros(1, nbits);
for j = 1 : nbits
    for k = 1 : nSamples
        if b(k,j)==1
            oneCount(1,j)=oneCount(1,j)+1;
        end
    end
    sortedCount=sort(oneCount,'descend');
    if oneCount(1,j)>sortedCount(1,ceil(nbits/15));
        bavg(1,j) = 1;
    end
end
nwords = ceil(nbits/8);
cb = zeros([1 nwords], 'uint8');
for j = 1:nbits
    w = ceil(j/8);
    cb(1,w) = bitset(cb(1,w), mod(j-1,8)+1, bavg(1,j));
end
