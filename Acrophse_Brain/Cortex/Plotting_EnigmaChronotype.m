addpath(genpath('F:\Toolbox\ENIGMA-2.0.0\ENIGMA-2.0.0\matlab'))
% 读取CSV文件
early = readtable('F:/PAtimingBrain/Acrophase_BMI/cortex/early.csv');
intermediate = readtable('F:/PAtimingBrain/Acrophase_BMI/cortex/intermediate.csv');
late = readtable('F:/PAtimingBrain/Acrophase_BMI/cortex/late.csv');
%corenigma7000 = readtable('D:/ukb_light_dementia/LightBrain_round2/cortex/cor_enigma_7000.csv');


% 定义保存路径
save_path = 'F:/PAtimingBrain/Acrophase_BMI/figures/';
%%%%%Beta

% early
early_cor_vol = early.beta_vol;
early_cor_vol_fsa5 = parcel_to_surface(early_cor_vol, 'aparc_fsa5');
f_cor_vol = figure;
plot_cortical(early_cor_vol_fsa5, 'surface_name', 'fsa5', 'color_range', [-0.3, 0.3], 'cmap', 'RdBu_r');
saveas(f_cor_vol, fullfile(save_path,'figure1_early_Volume.png'));

early_cor_area = early.beta_area;
early_cor_area_fsa5 = parcel_to_surface(early_cor_area, 'aparc_fsa5');
f_cor_area = figure;
plot_cortical(early_cor_area_fsa5, 'surface_name', 'fsa5', 'color_range', [-0.3, 0.3], 'cmap', 'RdBu_r');
saveas(f_cor_area, fullfile(save_path,'figure2_early_Area.png'));

early_cor_thickness = early.beta_thickness;
early_cor_thickness_fsa5 = parcel_to_surface(early_cor_thickness, 'aparc_fsa5');
f_cor_thickness = figure;
plot_cortical(early_cor_thickness_fsa5, 'surface_name', 'fsa5', 'color_range', [-0.3, 0.3], 'cmap', 'RdBu_r');
saveas(f_cor_thickness, fullfile(save_path,'figure3_early_Thickness.png'));

% 
intermediate_cor_vol = intermediate.beta_vol;
intermediate_cor_vol_fsa5 = parcel_to_surface(intermediate_cor_vol, 'aparc_fsa5');
f_cor_vol = figure;
plot_cortical(intermediate_cor_vol_fsa5, 'surface_name', 'fsa5', 'color_range', [-0.3, 0.3], 'cmap', 'RdBu_r');
saveas(f_cor_vol, fullfile(save_path,'figure4_intermediate_Volume.png'));

intermediate_cor_area = intermediate.beta_area;
intermediate_cor_area_fsa5 = parcel_to_surface(intermediate_cor_area, 'aparc_fsa5');
f_cor_area = figure;
plot_cortical(intermediate_cor_area_fsa5, 'surface_name', 'fsa5', 'color_range', [-0.3, 0.3], 'cmap', 'RdBu_r');
saveas(f_cor_area, fullfile(save_path,'figure5_intermediate_Area.png'));

intermediate_cor_thickness = intermediate.beta_thickness;
intermediate_cor_thickness_fsa5 = parcel_to_surface(intermediate_cor_thickness, 'aparc_fsa5');
f_cor_thickness = figure;
plot_cortical(intermediate_cor_thickness_fsa5, 'surface_name', 'fsa5', 'color_range', [-0.3, 0.3], 'cmap', 'RdBu_r');
saveas(f_cor_thickness, fullfile(save_path,'figure6_intermediate_Thickness.png'));

% 5000 Lux
late_cor_vol = late.beta_vol;
late_cor_vol_fsa5 = parcel_to_surface(late_cor_vol, 'aparc_fsa5');
f_cor_vol = figure;
plot_cortical(late_cor_vol_fsa5, 'surface_name', 'fsa5', 'color_range',[-0.3, 0.3], 'cmap', 'RdBu_r');
saveas(f_cor_vol, fullfile(save_path,'figure7_late_Volume.png'));

late_cor_area = late.beta_area;
late_cor_area_fsa5 = parcel_to_surface(late_cor_area, 'aparc_fsa5');
f_cor_area = figure;
plot_cortical(late_cor_area_fsa5, 'surface_name', 'fsa5', 'color_range', [-0.3, 0.3], 'cmap', 'RdBu_r');
saveas(f_cor_area, fullfile(save_path,'figure8_late_Area.png'));

late_cor_thickness = late.beta_thickness;
late_cor_thickness_fsa5 = parcel_to_surface(late_cor_thickness, 'aparc_fsa5');
f_cor_thickness = figure;
plot_cortical(late_cor_thickness_fsa5, 'surface_name', 'fsa5', 'color_range', [-0.3, 0.3], 'cmap', 'RdBu_r');
saveas(f_cor_thickness, fullfile(save_path,'figure9_late_Thickness.png'));


%%%%%P value

% 定义自定义颜色映射
custom_cmap = flipud(hot(64)); % 从白色到红色的渐变颜色

%%%%% P value

% early
early_cor_vol = early.p_log_vol;
early_cor_vol_fsa5 = parcel_to_surface(early_cor_vol, 'aparc_fsa5');
f_cor_vol = figure;
plot_cortical(early_cor_vol_fsa5, 'surface_name', 'fsa5', 'color_range', [0, 3.5], 'cmap', 'hot');
colormap(custom_cmap);
saveas(f_cor_vol, fullfile(save_path, 'early_cor_vol_p_log.png'));

early_cor_area = early.p_log_area;
early_cor_area_fsa5 = parcel_to_surface(early_cor_area, 'aparc_fsa5');
f_cor_area = figure;
plot_cortical(early_cor_area_fsa5, 'surface_name', 'fsa5', 'color_range', [0, 3.5], 'cmap', 'hot');
colormap(custom_cmap);
saveas(f_cor_area, fullfile(save_path, 'early_cor_area_p_log.png'));

early_cor_thickness = early.p_log_thickness;
early_cor_thickness_fsa5 = parcel_to_surface(early_cor_thickness, 'aparc_fsa5');
f_cor_thickness = figure;
plot_cortical(early_cor_thickness_fsa5, 'surface_name', 'fsa5', 'color_range', [0, 3.5], 'cmap', 'hot');
colormap(custom_cmap);
saveas(f_cor_thickness, fullfile(save_path, 'early_cor_thickness_p_log.png'));

% 3000lux
intermediate_cor_vol = intermediate.p_log_vol;
intermediate_cor_vol_fsa5 = parcel_to_surface(intermediate_cor_vol, 'aparc_fsa5');
f_cor_vol = figure;
plot_cortical(intermediate_cor_vol_fsa5, 'surface_name', 'fsa5', 'color_range', [0, 3.5], 'cmap', 'hot');
colormap(custom_cmap);
saveas(f_cor_vol, fullfile(save_path, 'intermediate_cor_vol_p_log.png'));

intermediate_cor_area = intermediate.p_log_area;
intermediate_cor_area_fsa5 = parcel_to_surface(intermediate_cor_area, 'aparc_fsa5');
f_cor_area = figure;
plot_cortical(intermediate_cor_area_fsa5, 'surface_name', 'fsa5', 'color_range', [0, 3.5], 'cmap', 'hot');
colormap(custom_cmap);
saveas(f_cor_area, fullfile(save_path, 'intermediate_cor_area_p_log.png'));

intermediate_cor_thickness = intermediate.p_log_thickness;
intermediate_cor_thickness_fsa5 = parcel_to_surface(intermediate_cor_thickness, 'aparc_fsa5');
f_cor_thickness = figure;
plot_cortical(intermediate_cor_thickness_fsa5, 'surface_name', 'fsa5', 'color_range', [0, 3.5], 'cmap', 'hot');
colormap(custom_cmap);
saveas(f_cor_thickness, fullfile(save_path, 'intermediate_cor_thickness_p_log.png'));

% 5000lux
late_cor_vol = late.p_log_vol;
late_cor_vol_fsa5 = parcel_to_surface(late_cor_vol, 'aparc_fsa5');
f_cor_vol = figure;
plot_cortical(late_cor_vol_fsa5, 'surface_name', 'fsa5', 'color_range', [0, 3.5], 'cmap', 'hot');
colormap(custom_cmap);
saveas(f_cor_vol, fullfile(save_path, 'late_cor_vol_p_log.png'));

late_cor_area = late.p_log_area;
late_cor_area_fsa5 = parcel_to_surface(late_cor_area, 'aparc_fsa5');
f_cor_area = figure;
plot_cortical(late_cor_area_fsa5, 'surface_name', 'fsa5', 'color_range', [0, 3.5], 'cmap', 'hot');
colormap(custom_cmap);
saveas(f_cor_area, fullfile(save_path, 'late_cor_area_p_log.png'));

late_cor_thickness = late.p_log_thickness;
late_cor_thickness_fsa5 = parcel_to_surface(late_cor_thickness, 'aparc_fsa5');
f_cor_thickness = figure;
plot_cortical(late_cor_thickness_fsa5, 'surface_name', 'fsa5', 'color_range', [0, 3.5], 'cmap', 'hot');
colormap(custom_cmap);
saveas(f_cor_thickness, fullfile(save_path, 'late_cor_thickness_p_log.png'));

