function outdata = cat_struct(data1,data2)

names = fieldnames(data1);
outdata = struct;
for ifield = 1:numel(names)
    if isfield(data2,(names{ifield}))
        subNames = fieldnames(data1.(names{ifield}));
        for isub = 1:numel(subNames)
            if ismember(subNames{isub},{'perturbID'}) % Create a unique ID for each perturbation (trial), by adding to perturbID the last value of the previous session
                data2.(names{ifield}).perturbID(find(data2.(names{ifield}).perturbID)) =...
                    data2.(names{ifield}).perturbID(find(data2.(names{ifield}).perturbID)) +...
                    max(data1.(names{ifield}).perturbID);
            end
            outdata.(names{ifield}).(subNames{isub}) = [data1.(names{ifield}).(subNames{isub}),...
                data2.(names{ifield}).(subNames{isub})];
        end
    end
end

end