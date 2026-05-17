clc;
clear;

%% Automatic welding head Simulink model builder
% Run this file in MATLAB. It creates one SLX file with three simulation
% diagrams corresponding to Fig. 2-1, Fig. 2-2 and Fig. 2-3 in the report.

model = 'welding_head_three_simulink';
outDir = fileparts(mfilename('fullpath'));
if isempty(outDir)
    outDir = pwd;
end

K1 = 20;
K2 = 0.2165;
Kc = 8;
z1 = 2;
p1 = 8;
z2 = 0.2;
p2 = 0.057;

if bdIsLoaded(model)
    set_param(model, 'Dirty', 'off');
    close_system(model, 0);
end

new_system(model);
open_system(model);
set_param(model, ...
    'StopTime', '8', ...
    'Solver', 'ode45', ...
    'ReturnWorkspaceOutputs', 'on');

addSubsystem(model, 'Fig2_1_basic_actual_connection', [80 70 430 230], ...
    sprintf('Fig.2-1 Basic scheme\\nK1 = %.4g, K2 = %.4g\\nGp(s)=1/[s(s+2)], H(s)=K2*s', K1, K2));
buildBasicSystem([model '/Fig2_1_basic_actual_connection'], K1, K2);

addSubsystem(model, 'Fig2_2_lead_lag_compensation', [520 70 910 230], ...
    sprintf('Fig.2-2 Lead-lag compensation\\nGc(s)=Kc(s+z1)(s+z2)/[(s+p1)(s+p2)]\\nKc=%g, z1=%g, p1=%g, z2=%g, p2=%g', Kc, z1, p1, z2, p2));
buildLeadLagSystem([model '/Fig2_2_lead_lag_compensation'], K1, K2, Kc, z1, p1, z2, p2);

addSubsystem(model, 'Fig2_3_disturbance_inputs', [80 320 430 500], ...
    sprintf('Fig.2-3 Disturbance input analysis\\nStep / ramp / sine disturbance added at output side\\nK1 = %.4g, K2 = %.4g', K1, K2));
buildDisturbanceSystem([model '/Fig2_3_disturbance_inputs'], K1, K2);

add_block('built-in/Note', [model '/Title'], ...
    'Position', [80 15 910 45], ...
    'Text', 'Automatic welding head control system: three Simulink simulation diagrams');

Simulink.BlockDiagram.arrangeSystem(model);
save_system(model, fullfile(outDir, [model '.slx']));

fprintf('Created %s\n', fullfile(outDir, [model '.slx']));

%% Local functions
function addSubsystem(model, name, pos, noteText)
    path = [model '/' name];
    add_block('built-in/Subsystem', path, 'Position', pos);
    deleteDefaultPorts(path);
    open_system(path);
    add_block('built-in/Note', [path '/Description'], ...
        'Position', [30 15 620 80], ...
        'Text', noteText);
end

function deleteDefaultPorts(sys)
    ports = find_system(sys, 'SearchDepth', 1, 'BlockType', 'Inport');
    for i = 1:numel(ports)
        delete_block(ports{i});
    end
    ports = find_system(sys, 'SearchDepth', 1, 'BlockType', 'Outport');
    for i = 1:numel(ports)
        delete_block(ports{i});
    end
end

function buildBasicSystem(sys, K1, K2)
    add_block('simulink/Sources/Step', [sys '/Step_R'], ...
        'Position', [40 130 70 160], 'Time', '0', 'Before', '0', 'After', '1');
    add_block('simulink/Sources/Ramp', [sys '/Ramp_R'], ...
        'Position', [40 190 70 220], 'slope', '1', 'start', '0', 'InitialOutput', '0');
    add_block('simulink/Signal Routing/Manual Switch', [sys '/R_select'], ...
        'Position', [110 140 150 210]);
    add_block('simulink/Math Operations/Sum', [sys '/Error_sum'], ...
        'Position', [200 150 230 180], 'Inputs', '+-');
    add_block('simulink/Math Operations/Gain', [sys '/K1_gain'], ...
        'Position', [285 145 350 185], 'Gain', num2str(K1));
    add_block('simulink/Continuous/Transfer Fcn', [sys '/Plant_Gp_1_over_s_splus2'], ...
        'Position', [405 140 515 190], 'Numerator', '[1]', 'Denominator', '[1 2 0]');
    add_block('simulink/Sources/Step', [sys '/Disturbance_D'], ...
        'Position', [405 60 435 90], 'Time', '100', 'Before', '0', 'After', '0');
    add_block('simulink/Math Operations/Sum', [sys '/Output_disturbance_sum'], ...
        'Position', [575 145 605 175], 'Inputs', '++');
    add_block('simulink/Sinks/Scope', [sys '/Scope_Y'], ...
        'Position', [700 125 735 165]);
    add_block('simulink/Sinks/To Workspace', [sys '/ToWorkspace_Y_basic'], ...
        'Position', [690 180 780 210], 'VariableName', 'Y_basic', 'SaveFormat', 'StructureWithTime');
    add_block('simulink/Continuous/Derivative', [sys '/Velocity_derivative_s'], ...
        'Position', [375 275 430 315]);
    add_block('simulink/Math Operations/Gain', [sys '/K2_velocity_gain'], ...
        'Position', [470 270 545 320], 'Gain', num2str(K2));

    add_line(sys, 'Step_R/1', 'R_select/1', 'autorouting', 'on');
    add_line(sys, 'Ramp_R/1', 'R_select/2', 'autorouting', 'on');
    add_line(sys, 'R_select/1', 'Error_sum/1', 'autorouting', 'on');
    add_line(sys, 'Error_sum/1', 'K1_gain/1', 'autorouting', 'on');
    add_line(sys, 'K1_gain/1', 'Plant_Gp_1_over_s_splus2/1', 'autorouting', 'on');
    add_line(sys, 'Plant_Gp_1_over_s_splus2/1', 'Output_disturbance_sum/1', 'autorouting', 'on');
    add_line(sys, 'Disturbance_D/1', 'Output_disturbance_sum/2', 'autorouting', 'on');
    add_line(sys, 'Output_disturbance_sum/1', 'Scope_Y/1', 'autorouting', 'on');
    add_line(sys, 'Output_disturbance_sum/1', 'ToWorkspace_Y_basic/1', 'autorouting', 'on');
    add_line(sys, 'Output_disturbance_sum/1', 'Velocity_derivative_s/1', 'autorouting', 'on');
    add_line(sys, 'Velocity_derivative_s/1', 'K2_velocity_gain/1', 'autorouting', 'on');
    add_line(sys, 'K2_velocity_gain/1', 'Error_sum/2', 'autorouting', 'on');

    Simulink.BlockDiagram.arrangeSystem(sys);
end

function buildLeadLagSystem(sys, K1, K2, Kc, z1, p1, z2, p2)
    alpha = 2 + K1 * K2;
    plantNum = K1;
    plantDen = [1 alpha 0];
    gcNum = Kc * conv([1 z1], [1 z2]);
    gcDen = conv([1 p1], [1 p2]);

    add_block('simulink/Sources/Step', [sys '/Step_R'], ...
        'Position', [40 150 70 180], 'Time', '0', 'Before', '0', 'After', '1');
    add_block('simulink/Math Operations/Sum', [sys '/Error_sum'], ...
        'Position', [140 150 170 180], 'Inputs', '+-');
    add_block('simulink/Continuous/Transfer Fcn', [sys '/Lead_lag_controller_Gc'], ...
        'Position', [230 135 385 195], ...
        'Numerator', mat2str(gcNum, 12), ...
        'Denominator', mat2str(gcDen, 12));
    add_block('simulink/Continuous/Transfer Fcn', [sys '/Base_equivalent_plant'], ...
        'Position', [455 135 600 195], ...
        'Numerator', mat2str(plantNum, 12), ...
        'Denominator', mat2str(plantDen, 12));
    add_block('simulink/Sinks/Scope', [sys '/Scope_Y_comp'], ...
        'Position', [705 135 740 175]);
    add_block('simulink/Sinks/To Workspace', [sys '/ToWorkspace_Y_comp'], ...
        'Position', [695 195 790 225], 'VariableName', 'Y_comp', 'SaveFormat', 'StructureWithTime');

    add_block('built-in/Note', [sys '/Gc_formula'], ...
        'Position', [230 65 610 105], ...
        'Text', 'Gc(s)=8(s+2)(s+0.2)/[(s+8)(s+0.057)], then series with base equivalent plant 20/[s(s+6.33)]');

    add_line(sys, 'Step_R/1', 'Error_sum/1', 'autorouting', 'on');
    add_line(sys, 'Error_sum/1', 'Lead_lag_controller_Gc/1', 'autorouting', 'on');
    add_line(sys, 'Lead_lag_controller_Gc/1', 'Base_equivalent_plant/1', 'autorouting', 'on');
    add_line(sys, 'Base_equivalent_plant/1', 'Scope_Y_comp/1', 'autorouting', 'on');
    add_line(sys, 'Base_equivalent_plant/1', 'ToWorkspace_Y_comp/1', 'autorouting', 'on');
    add_line(sys, 'Base_equivalent_plant/1', 'Error_sum/2', 'autorouting', 'on');

    Simulink.BlockDiagram.arrangeSystem(sys);
end

function buildDisturbanceSystem(sys, K1, K2)
    add_block('simulink/Sources/Step', [sys '/Step_R'], ...
        'Position', [40 145 70 175], 'Time', '0', 'Before', '0', 'After', '1');
    add_block('simulink/Math Operations/Sum', [sys '/Error_sum'], ...
        'Position', [140 145 170 175], 'Inputs', '+-');
    add_block('simulink/Math Operations/Gain', [sys '/K1_gain'], ...
        'Position', [230 140 295 180], 'Gain', num2str(K1));
    add_block('simulink/Continuous/Transfer Fcn', [sys '/Plant_Gp_1_over_s_splus2'], ...
        'Position', [355 135 465 185], 'Numerator', '[1]', 'Denominator', '[1 2 0]');

    add_block('simulink/Sources/Step', [sys '/Step_D'], ...
        'Position', [350 40 380 70], 'Time', '1', 'Before', '0', 'After', '1');
    add_block('simulink/Sources/Ramp', [sys '/Ramp_D'], ...
        'Position', [350 85 380 115], 'slope', '1', 'start', '1', 'InitialOutput', '0');
    add_block('simulink/Sources/Sine Wave', [sys '/Sine_D'], ...
        'Position', [350 230 380 260], 'Amplitude', '1', 'Frequency', '3');
    add_block('simulink/Signal Routing/Manual Switch', [sys '/D_select_1'], ...
        'Position', [425 55 465 120]);
    add_block('simulink/Signal Routing/Manual Switch', [sys '/D_select_2'], ...
        'Position', [505 85 545 190]);
    add_block('simulink/Math Operations/Sum', [sys '/Output_disturbance_sum'], ...
        'Position', [595 145 625 175], 'Inputs', '++');
    add_block('simulink/Sinks/Scope', [sys '/Scope_Y_dist'], ...
        'Position', [725 130 760 170]);
    add_block('simulink/Sinks/To Workspace', [sys '/ToWorkspace_Y_dist'], ...
        'Position', [710 190 805 220], 'VariableName', 'Y_dist', 'SaveFormat', 'StructureWithTime');
    add_block('simulink/Continuous/Derivative', [sys '/Velocity_derivative_s'], ...
        'Position', [375 285 430 325]);
    add_block('simulink/Math Operations/Gain', [sys '/K2_velocity_gain'], ...
        'Position', [470 280 545 330], 'Gain', num2str(K2));

    add_line(sys, 'Step_R/1', 'Error_sum/1', 'autorouting', 'on');
    add_line(sys, 'Error_sum/1', 'K1_gain/1', 'autorouting', 'on');
    add_line(sys, 'K1_gain/1', 'Plant_Gp_1_over_s_splus2/1', 'autorouting', 'on');
    add_line(sys, 'Plant_Gp_1_over_s_splus2/1', 'Output_disturbance_sum/1', 'autorouting', 'on');
    add_line(sys, 'Step_D/1', 'D_select_1/1', 'autorouting', 'on');
    add_line(sys, 'Ramp_D/1', 'D_select_1/2', 'autorouting', 'on');
    add_line(sys, 'D_select_1/1', 'D_select_2/1', 'autorouting', 'on');
    add_line(sys, 'Sine_D/1', 'D_select_2/2', 'autorouting', 'on');
    add_line(sys, 'D_select_2/1', 'Output_disturbance_sum/2', 'autorouting', 'on');
    add_line(sys, 'Output_disturbance_sum/1', 'Scope_Y_dist/1', 'autorouting', 'on');
    add_line(sys, 'Output_disturbance_sum/1', 'ToWorkspace_Y_dist/1', 'autorouting', 'on');
    add_line(sys, 'Output_disturbance_sum/1', 'Velocity_derivative_s/1', 'autorouting', 'on');
    add_line(sys, 'Velocity_derivative_s/1', 'K2_velocity_gain/1', 'autorouting', 'on');
    add_line(sys, 'K2_velocity_gain/1', 'Error_sum/2', 'autorouting', 'on');

    Simulink.BlockDiagram.arrangeSystem(sys);
end
