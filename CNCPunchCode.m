function gcode_optimizer(input_file, output_file)
% GCODE_OPTIMIZER - Inserts solenoid punch commands every 3 lines for pointillism patterns
% Developed by: [Your Name]
% Input: input_file - Original G-code file
%        output_file - Optimized G-code with punch commands

    % Read the original G-code file
    fid = fopen(input_file, 'r');
    gcode_lines = {};
    
    tline = fgetl(fid);
    while ischar(tline)
        gcode_lines{end+1} = tline;
        tline = fgetl(fid);
    end
    fclose(fid);
    
    % Process and optimize G-code
    optimized_gcode = {};
    line_count = 0;
    
    for i = 1:length(gcode_lines)
        current_line = gcode_lines{i};
        optimized_gcode{end+1} = current_line;
        
        % Check if it's a movement command (G1)
        if startsWith(strtrim(current_line), 'G1') && contains(current_line, ['X', 'Y'])
            line_count = line_count + 1;
            
            % Insert solenoid punch command every 3 movement lines
            if mod(line_count, 3) == 0
                optimized_gcode{end+1} = '; --- SOLENOID PUNCH (Pointillism) ---';
                optimized_gcode{end+1} = 'M106 S255 ; Actuate solenoid - PUNCH';
                optimized_gcode{end+1} = 'G4 P500 ; Wait 500ms';
                optimized_gcode{end+1} = 'M106 S0 ; Retract solenoid';
                optimized_gcode{end+1} = '; ---------------------------------';
            end
        end
    end
    
    % Write optimized G-code to output file
    fid = fopen(output_file, 'w');
    for i = 1:length(optimized_gcode)
        fprintf(fid, '%s\n', optimized_gcode{i});
    end
    fclose(fid);
    
    fprintf('G-code optimization complete!\n');
    fprintf('Input: %s\n', input_file);
    fprintf('Output: %s\n', output_file);
    fprintf('Total lines processed: %d\n', length(gcode_lines));
    fprintf('Punch commands inserted: %d\n', floor(line_count/3));
end

% Additional function for processing specific G-code patterns
function process_gcode(input_file, output_file)
% PROCESS_GCODE - Main function to handle G-code optimization workflow
    
    fprintf('Starting G-code optimization workflow...\n');
    
    % Step 1: Optimize for pointillism patterns
    gcode_optimizer(input_file, output_file);
    
    % Step 2: Validate the output
    validate_gcode(output_file);
    
    fprintf('Workflow completed successfully!\n');
end

function validate_gcode(filename)
% VALIDATE_GCODE - Basic validation of optimized G-code
    fid = fopen(filename, 'r');
    punch_count = 0;
    move_count = 0;
    
    tline = fgetl(fid);
    while ischar(tline)
        if contains(tline, 'SOLENOID PUNCH')
            punch_count = punch_count + 1;
        elseif startsWith(strtrim(tline), 'G1')
            move_count = move_count + 1;
        end
        tline = fgetl(fid);
    end
    fclose(fid);
    
    fprintf('G-code Validation Results:\n');
    fprintf(' - Movement commands: %d\n', move_count);
    fprintf(' - Punch commands: %d\n', punch_count);
    fprintf(' - Punch frequency: 1 every %.1f movements\n', move_count/max(punch_count,1));
end