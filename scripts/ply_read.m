function data = ply_read(filename)
    opts = delimitedTextImportOptions("NumVariables", 9);
    
    
    opts.DataLines = [14, Inf];
    opts.Delimiter = " ";
    
    
    opts.VariableNames = ["ply", "VarName2", "VarName3", "VarName4", "VarName5", "VarName6", "VarName7", "VarName8", "VarName9"];
    opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double"];
    
    
    opts.ExtraColumnsRule = "ignore";
    opts.EmptyLineRule = "read";
    opts.ConsecutiveDelimitersRule = "join";
    opts.LeadingDelimitersRule = "ignore";
    
    
    I = readtable(filename, opts);
    data = pointCloud(I{:,1:3},'color',I{:,4:6}./255,'intensity',I{:,7});

    clear opts
end