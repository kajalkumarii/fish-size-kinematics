function diffVec = fivepoint(vec,dt)
%Compute 5-point stencil to extract speed from position
vec = vec(:);
coeffMat = repmat([1 -8 0 8 -1],numel(vec),1);
shiftedVec = makehistory(vec,4);
smoothedVec = transpose(dot(shiftedVec',coeffMat')./(12*dt));
diffVec = [smoothedVec(3:end); nan(2,1)];
end