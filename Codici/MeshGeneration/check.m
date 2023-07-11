function [] = check(status)
%CHECK Summary of this function goes here
%   Detailed explanation goes here
if status == 0
        disp('WSL commands executed successfully.');
        disp('Output:');
        disp(result);
    else
        disp('Failed to execute WSL commands.');
        disp('Error message:');
        disp(result);
end

end

