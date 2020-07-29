clear
clc
% tip: ��������Ũ�ȣ�ģʽ�ֲ�Ũ��
load('coastlines.mat');  % ���غ���������
plot(coastlon,coastlat)
hold on

info_model = ncinfo('mod\GEOSChem.SpeciesConc.20140101_0000z.nc4');
info_sat = ncinfo('sat\20140101-C3S-L2_GHG-GHG_PRODUCTS-TANSO-GOSAT-OCFP-DAILY-v7.2.nc');

%% ------------------------------------1�·ݱȽ�-----------------------------------
files_sat = dir('sat\*.nc');
files_model = dir('mod\*.nc4');
% ģʽ����
ch4_model = ncread(['mod\',files_model(1).name],'SpeciesConc_CH4'); %  {'mol mol-1 dry'}
lon_model = ncread(['mod\',files_model(1).name],'lon');
lat_model = ncread(['mod\',files_model(1).name],'lat');
lev_model = ncread(['mod\',files_model(1).name],'lev'); % ģʽ������ѹ��
time_model = ncread(['mod\',files_model(1).name],'time');
temp_model = [];
temp_sat = [];
for i = 1 : 31   % 1��31���ļ�
    disp(['���ڴ���1��',files_sat(i).name(7:8),'������'])
    lon_sat = ncread(['sat\',files_sat(i).name],'longitude');
    lat_sat = ncread(['sat\',files_sat(i).name],'latitude');
    lev_sat = ncread(['sat\',files_sat(i).name],'pressure_levels'); % sat��ѹ��
    pw_sat = ncread(['sat\',files_sat(i).name],'pressure_weight');
    ch4_pa_sat = ncread(['sat\',files_sat(i).name],'ch4_profile_apriori');
    xch4_ak_sat = ncread(['sat\',files_sat(i).name],'xch4_averaging_kernel');
    xch4_sat = ncread(['sat\',files_sat(i).name],'xch4');  % ��λ��ppb
    scatter(lon_sat,lat_sat)
    [m_lon,m_lat] = meshgrid(lon_model,lat_model);
    % �Ӹ߶Ȳ�ֵ���ģʽ����ѡȡ�����ǹ۲�λ�õ�����
    for n = 1 : length(lon_sat)
        for yy = 1 : size(m_lon,2)
            if lon_sat(n,1) < lon_model(yy,1)
                position_mark(n,1) = yy;  % ��¼�������ڸ��λ��
                break
            else
                position_mark(n,1) = 144;
            end
        end
    end
    for n = 1 : length(lon_sat)
        for xx = 1 : size(m_lon,1)
            if lat_sat(n,1) < lat_model(xx,1)
                position_mark(n,2) = xx;  % ��¼γ�����ڸ��λ��
                break
            end
        end
    end
    % ת������Ũ��
    for lon_x = 1 : length(lon_model)
        for lat_y = 1 : length(lat_model)
            ch4_interp_model(lon_x,lat_y,:,i) = ...
                interp1(lev_model*1000,squeeze(ch4_model(lon_x,lat_y,:,i)),lev_sat(:,1),'method'); % ��ģʽ�������ݲ�ֵ��ͬ����ͬ��
        end
    end
    for j = 1 : length(xch4_sat) % ÿ��۲�λ����
        for k = 1 : 20
            ch4_slip_model(k,j) = ...
                (ch4_pa_sat(k,j) + (ch4_interp_model(position_mark(j,1),position_mark(j,2),k,i)*10^9 - ch4_pa_sat(k,j)) * xch4_ak_sat(k,j)) * pw_sat(k,j); % תΪ��Ũ��
        end
    end
    eval(['ch4_column_model',files_sat(i).name(5:8),'= sum(ch4_slip_model,1);']); % ÿ����۲���ģʽ������Ũ��
    ch4_column_model = sum(ch4_slip_model,1);
    % ����--ģʽ���ݱȽ�
    RMSe1(i,1) = sqrt(sum((ch4_column_model - xch4_sat').^2)/length(xch4_sat));  %RMSE�����������ݵĲ���
    
    temp_model = [temp_model;ch4_column_model'];
    temp_sat = [temp_sat;xch4_sat];
    
    clear position_mark ch4_slip_model;
end
ave_model1 = mean(temp_model);
ave_sat1 = mean(temp_sat);
%% ----------------------------------------2�·ݱȽ�-----------------------------------
files_sat = dir('sat2\*.nc');
files_model = dir('mod\*.nc4');
% mod
ch4_model = ncread(['mod\',files_model(2).name],'SpeciesConc_CH4'); %  {'mol mol-1 dry'}
lon_model = ncread(['mod\',files_model(2).name],'lon');
lat_model = ncread(['mod\',files_model(2).name],'lat');
lev_model = ncread(['mod\',files_model(2).name],'lev'); % ģʽ������ѹ��
time_model = ncread(['mod\',files_model(2).name],'time');
temp_model = [];
temp_sat = [];
for i = 1 : 26   % 1��31���ļ�
    disp(['���ڴ���2��',files_sat(i).name(7:8),'������'])
    lon_sat = ncread(['sat2\',files_sat(i).name],'longitude');
    lat_sat = ncread(['sat2\',files_sat(i).name],'latitude');
    lev_sat = ncread(['sat2\',files_sat(i).name],'pressure_levels'); % ����������ѹ��
    pw_sat = ncread(['sat2\',files_sat(i).name],'pressure_weight');
    ch4_pa_sat = ncread(['sat2\',files_sat(i).name],'ch4_profile_apriori');
    xch4_ak_sat = ncread(['sat2\',files_sat(i).name],'xch4_averaging_kernel');
    xch4_sat = ncread(['sat2\',files_sat(i).name],'xch4');  % ��λ��ppb
    %     scatter(lon_sat,lat_sat)
    [m_lon,m_lat] = meshgrid(lon_model,lat_model);
    % �Ӹ߶Ȳ�ֵ���ģʽ����ѡȡ�����ǹ۲�λ�õ�����
    for n = 1 : length(lon_sat)
        for yy = 1 : size(m_lon,2)
            if lon_sat(n,1) < lon_model(yy,1)
                position_mark(n,1) = yy;  % ��¼�������ڸ��λ��
                break
            else
                position_mark(n,1) = 144;
            end
        end
    end
    for n = 1 : length(lon_sat)
        for xx = 1 : size(m_lon,1)
            if lat_sat(n,1) < lat_model(xx,1)
                position_mark(n,2) = xx;  % ��¼γ�����ڸ��λ��
                break
            end
        end
    end
    % ת������Ũ��
    for lon_x = 1 : length(lon_model)
        for lat_y = 1 : length(lat_model)
            ch4_interp_model(lon_x,lat_y,:,i) = ...
                interp1(lev_model*1000,squeeze(ch4_model(lon_x,lat_y,:,i)),lev_sat(:,1),'method'); % ��ģʽ�������ݲ�ֵ��ͬ����ͬ��
        end
    end
    for j = 1 : length(xch4_sat) % ÿ��۲�λ����
        for k = 1 : 20
            ch4_slip_model(k,j) = ...
                (ch4_pa_sat(k,j) + (ch4_interp_model(position_mark(j,1),position_mark(j,2),k,i)*10^9 - ch4_pa_sat(k,j)) * xch4_ak_sat(k,j)) * pw_sat(k,j); % תΪ��Ũ��
        end
    end
    eval(['ch4_column_model',files_sat(i).name(5:8),'= sum(ch4_slip_model,1);']); % ÿ����۲���mod��Ũ��
    ch4_column_model = sum(ch4_slip_model,1);
    % ����--mod�Ƚ�
    RMSe2(i,1) = sqrt(sum((ch4_column_model - xch4_sat').^2)/length(xch4_sat));  %RMSE�����������ݵĲ���
    temp_model = [temp_model;ch4_column_model'];
    temp_sat = [temp_sat;xch4_sat];
    clear position_mark ch4_slip_model;
end
ave_model2 = mean(temp_model,'omitnan');
ave_sat2 = mean(temp_sat);

%% ----------------------------------------3�·ݱȽ�----------------------------------
files_sat = dir('sat3\*.nc');
files_model = dir('mod\*.nc4');
% ģʽ����
ch4_model = ncread(['mod\',files_model(3).name],'SpeciesConc_CH4'); %  {'mol mol-1 dry'}
lon_model = ncread(['mod\',files_model(3).name],'lon');
lat_model = ncread(['mod\',files_model(3).name],'lat');
lev_model = ncread(['mod\',files_model(3).name],'lev'); % ģʽ������ѹ��
time_model = ncread(['mod\',files_model(3).name],'time');
temp_model = [];
temp_sat = [];
for i = 1 : 31   % 1��31���ļ�
    disp(['���ڴ���3��',files_sat(i).name(7:8),'������'])
    lon_sat = ncread(['sat3\',files_sat(i).name],'longitude');
    lat_sat = ncread(['sat3\',files_sat(i).name],'latitude');
    lev_sat = ncread(['sat3\',files_sat(i).name],'pressure_levels'); % ����������ѹ��
    pw_sat = ncread(['sat3\',files_sat(i).name],'pressure_weight');
    ch4_pa_sat = ncread(['sat3\',files_sat(i).name],'ch4_profile_apriori');
    xch4_ak_sat = ncread(['sat3\',files_sat(i).name],'xch4_averaging_kernel');
    xch4_sat = ncread(['sat3\',files_sat(i).name],'xch4');  % ��λ��ppb
    %     scatter(lon_sat,lat_sat)
    [m_lon,m_lat] = meshgrid(lon_model,lat_model);
    % �Ӹ߶Ȳ�ֵ���ģʽ����ѡȡ�����ǹ۲�λ�õ�����
    for n = 1 : length(lon_sat)
        for yy = 1 : size(m_lon,2)
            if lon_sat(n,1) < lon_model(yy,1)
                position_mark(n,1) = yy;  % ��¼�������ڸ��λ��
                break
            else
                position_mark(n,1) = 144;
            end
        end
    end
    for n = 1 : length(lon_sat)
        for xx = 1 : size(m_lon,1)
            if lat_sat(n,1) < lat_model(xx,1)
                position_mark(n,2) = xx;  % ��¼γ�����ڸ��λ��
                break
            end
        end
    end
    % ת������Ũ��
    for lon_x = 1 : length(lon_model)
        for lat_y = 1 : length(lat_model)
            ch4_interp_model(lon_x,lat_y,:,i) = ...
                interp1(lev_model*1000,squeeze(ch4_model(lon_x,lat_y,:,i)),lev_sat(:,1),'method'); % ��ģʽ�������ݲ�ֵ��ͬ����ͬ��
        end
    end
    for j = 1 : length(xch4_sat) % ÿ��۲�λ����
        for k = 1 : 20
            ch4_slip_model(k,j) = ...
                (ch4_pa_sat(k,j) + (ch4_interp_model(position_mark(j,1),position_mark(j,2),k,i)*10^9 - ch4_pa_sat(k,j)) * xch4_ak_sat(k,j)) * pw_sat(k,j); % תΪ��Ũ��
        end
    end
    eval(['ch4_column_model',files_sat(i).name(5:8),'= sum(ch4_slip_model,1);']); % ÿ����۲���ģʽ������Ũ��
    ch4_column_model = sum(ch4_slip_model,1);
    % ����--ģʽ���ݱȽ�
    RMSe3(i,1) = sqrt(sum((ch4_column_model - xch4_sat').^2)/length(xch4_sat));  %RMSE�����������ݵĲ���
    temp_model = [temp_model;ch4_column_model'];
    temp_sat = [temp_sat;xch4_sat];
    clear position_mark ch4_slip_model;
end
ave_model3 = mean(temp_model);
ave_sat3 = mean(temp_sat);
%% ----------------------------------------4�·ݱȽ�----------------------------------
files_sat = dir('sat4\*.nc');
files_model = dir('mod\*.nc4');
% ģʽ����
ch4_model = ncread(['mod\',files_model(3).name],'SpeciesConc_CH4'); %  {'mol mol-1 dry'}
lon_model = ncread(['mod\',files_model(3).name],'lon');
lat_model = ncread(['mod\',files_model(3).name],'lat');
lev_model = ncread(['mod\',files_model(3).name],'lev'); % ģʽ������ѹ��
time_model = ncread(['mod\',files_model(3).name],'time');
temp_model = [];
temp_sat = [];
for i = 1 : 30   % 1��31���ļ�
    disp(['���ڴ���4��',files_sat(i).name(7:8),'������'])
    lon_sat = ncread(['sat4\',files_sat(i).name],'longitude');
    lat_sat = ncread(['sat4\',files_sat(i).name],'latitude');
    lev_sat = ncread(['sat4\',files_sat(i).name],'pressure_levels'); % sat��ѹ��
    pw_sat = ncread(['sat4\',files_sat(i).name],'pressure_weight');
    ch4_pa_sat = ncread(['sat4\',files_sat(i).name],'ch4_profile_apriori');
    xch4_ak_sat = ncread(['sat4\',files_sat(i).name],'xch4_averaging_kernel');
    xch4_sat = ncread(['sat4\',files_sat(i).name],'xch4');  % ��λ��ppb
    %     scatter(lon_sat,lat_sat)
    [m_lon,m_lat] = meshgrid(lon_model,lat_model);
    % �Ӹ߶Ȳ�ֵ���ģʽ����ѡȡ�����ǹ۲�λ�õ�����
    for n = 1 : length(lon_sat)
        for yy = 1 : size(m_lon,2)
            if lon_sat(n,1) < lon_model(yy,1)
                position_mark(n,1) = yy;  % ��¼�������ڸ��λ��
                break
            else
                position_mark(n,1) = 144;
            end
        end
    end
    for n = 1 : length(lon_sat)
        for xx = 1 : size(m_lon,1)
            if lat_sat(n,1) < lat_model(xx,1)
                position_mark(n,2) = xx;  % ��¼γ�����ڸ��λ��
                break
            end
        end
    end
    % ת������Ũ��
    for lon_x = 1 : length(lon_model)
        for lat_y = 1 : length(lat_model)
            ch4_interp_model(lon_x,lat_y,:,i) = ...
                interp1(lev_model*1000,squeeze(ch4_model(lon_x,lat_y,:,i)),lev_sat(:,1),'method'); % ��ģʽ�������ݲ�ֵ��ͬ����ͬ��
        end
    end
    for j = 1 : length(xch4_sat) % ÿ��۲�λ����
        for k = 1 : 20
            ch4_slip_model(k,j) = ...
                (ch4_pa_sat(k,j) + (ch4_interp_model(position_mark(j,1),position_mark(j,2),k,i)*10^9 - ch4_pa_sat(k,j)) * xch4_ak_sat(k,j)) * pw_sat(k,j); % תΪ��Ũ��
        end
    end
    eval(['ch4_column_model',files_sat(i).name(5:8),'= sum(ch4_slip_model,1);']); % ÿ����۲���ģʽ������Ũ��
    ch4_column_model = sum(ch4_slip_model,1);
    % ����--ģʽ���ݱȽ�
    RMSe4(i,1) = sqrt(sum((ch4_column_model - xch4_sat').^2)/length(xch4_sat));  %RMSE�����������ݵĲ���
    temp_model = [temp_model;ch4_column_model'];
    temp_sat = [temp_sat;xch4_sat];
    clear position_mark ch4_slip_model;
end
ave_model4 = mean(temp_model);
ave_sat4 = mean(temp_sat);
%% ----------------------------------------5�·ݱȽ�----------------------------------
files_sat = dir('sat5\*.nc');
files_model = dir('mod\*.nc4');
% ģʽ����
ch4_model = ncread(['mod\',files_model(5).name],'SpeciesConc_CH4'); %  {'mol mol-1 dry'}
lon_model = ncread(['mod\',files_model(5).name],'lon');
lat_model = ncread(['mod\',files_model(5).name],'lat');
lev_model = ncread(['mod\',files_model(5).name],'lev'); % ģʽ������ѹ��
time_model = ncread(['mod\',files_model(5).name],'time');
temp_model = [];
temp_sat = [];
for i = 1 : 25   % 1��31���ļ�
    
    disp(['���ڴ���5��',files_sat(i).name(7:8),'������'])
    lon_sat = ncread(['sat5\',files_sat(i).name],'longitude');
    lat_sat = ncread(['sat5\',files_sat(i).name],'latitude');
    lev_sat = ncread(['sat5\',files_sat(i).name],'pressure_levels'); % sat��ѹ��
    pw_sat = ncread(['sat5\',files_sat(i).name],'pressure_weight');
    ch4_pa_sat = ncread(['sat5\',files_sat(i).name],'ch4_profile_apriori');
    xch4_ak_sat = ncread(['sat5\',files_sat(i).name],'xch4_averaging_kernel');
    xch4_sat = ncread(['sat5\',files_sat(i).name],'xch4');  % ��λ��ppb
    %     scatter(lon_sat,lat_sat)
    [m_lon,m_lat] = meshgrid(lon_model,lat_model);
    % �Ӹ߶Ȳ�ֵ���ģʽ����ѡȡ�����ǹ۲�λ�õ�����
    for n = 1 : length(lon_sat)
        for yy = 1 : size(m_lon,2)
            if lon_sat(n,1) < lon_model(yy,1)
                position_mark(n,1) = yy;  % ��¼�������ڸ��λ��
                break
            else
                position_mark(n,1) = 144;
            end
        end
    end
    for n = 1 : length(lon_sat)
        for xx = 1 : size(m_lon,1)
            if lat_sat(n,1) < lat_model(xx,1)
                position_mark(n,2) = xx;  % ��¼γ�����ڸ��λ��
                break
            end
        end
    end
    % ת������Ũ��
    for lon_x = 1 : length(lon_model)
        for lat_y = 1 : length(lat_model)
            ch4_interp_model(lon_x,lat_y,:,i) = ...
                interp1(lev_model*1000,squeeze(ch4_model(lon_x,lat_y,:,i)),lev_sat(:,1),'method'); % ��ģʽ�������ݲ�ֵ��ͬ����ͬ��
        end
    end
    for j = 1 : length(xch4_sat) % ÿ��۲�λ����
        for k = 1 : 20
            ch4_slip_model(k,j) = ...
                (ch4_pa_sat(k,j) + (ch4_interp_model(position_mark(j,1),position_mark(j,2),k,i)*10^9 - ch4_pa_sat(k,j)) * xch4_ak_sat(k,j)) * pw_sat(k,j); % תΪ��Ũ��
        end
    end
    eval(['ch4_column_model',files_sat(i).name(5:8),'= sum(ch4_slip_model,1);']); % ÿ����۲���ģʽ������Ũ��
    ch4_column_model = sum(ch4_slip_model,1);
    % ����--ģʽ���ݱȽ�
    RMSe5(i,1) = sqrt(sum((ch4_column_model - xch4_sat').^2)/length(xch4_sat));  %RMSE�����������ݵĲ���
    temp_model = [temp_model;ch4_column_model'];
    temp_sat = [temp_sat;xch4_sat];
    clear position_mark ch4_slip_model;
end
ave_model5 = mean(temp_model);
ave_sat5 = mean(temp_sat);
%% ----------------------------------------6�·ݱȽ�----------------------------------
files_sat = dir('sat6\*.nc');
files_model = dir('mod\*.nc4');
% mod
ch4_model = ncread(['mod\',files_model(6).name],'SpeciesConc_CH4'); %  {'mol mol-1 dry'}
lon_model = ncread(['mod\',files_model(6).name],'lon');
lat_model = ncread(['mod\',files_model(6).name],'lat');
lev_model = ncread(['mod\',files_model(6).name],'lev'); % ģʽ������ѹ��
time_model = ncread(['mod\',files_model(6).name],'time');
temp_model = [];
temp_sat = [];
for i = 1 : 30   % 1��31���ļ�
    disp(['���ڴ���6��',files_sat(i).name(7:8),'������'])
    lon_sat = ncread(['sat6\',files_sat(i).name],'longitude');
    lat_sat = ncread(['sat6\',files_sat(i).name],'latitude');
    lev_sat = ncread(['sat6\',files_sat(i).name],'pressure_levels'); % sat��ѹ��
    pw_sat = ncread(['sat6\',files_sat(i).name],'pressure_weight');
    ch4_pa_sat = ncread(['sat6\',files_sat(i).name],'ch4_profile_apriori');
    xch4_ak_sat = ncread(['sat6\',files_sat(i).name],'xch4_averaging_kernel');
    xch4_sat = ncread(['sat6\',files_sat(i).name],'xch4');  % ��λ��ppb
    %     scatter(lon_sat,lat_sat)
    [m_lon,m_lat] = meshgrid(lon_model,lat_model);
    % �Ӹ߶Ȳ�ֵ���ģʽ����ѡȡ�����ǹ۲�λ�õ�����
    for n = 1 : length(lon_sat)
        for yy = 1 : size(m_lon,2)
            if lon_sat(n,1) < lon_model(yy,1)
                position_mark(n,1) = yy;  % ��¼�������ڸ��λ��
                break
            else
                position_mark(n,1) = 144;
            end
        end
    end
    for n = 1 : length(lon_sat)
        for xx = 1 : size(m_lon,1)
            if lat_sat(n,1) < lat_model(xx,1)
                position_mark(n,2) = xx;  % ��¼γ�����ڸ��λ��
                break
            end
        end
    end
    % ת������Ũ��
    for lon_x = 1 : length(lon_model)
        for lat_y = 1 : length(lat_model)
            ch4_interp_model(lon_x,lat_y,:,i) = ...
                interp1(lev_model*1000,squeeze(ch4_model(lon_x,lat_y,:,i)),lev_sat(:,1),'method'); % ��ģʽ�������ݲ�ֵ��ͬ����ͬ��
        end
    end
    for j = 1 : length(xch4_sat) % ÿ��۲�λ����
        for k = 1 : 20
            ch4_slip_model(k,j) = ...
                (ch4_pa_sat(k,j) + (ch4_interp_model(position_mark(j,1),position_mark(j,2),k,i)*10^9 - ch4_pa_sat(k,j)) * xch4_ak_sat(k,j)) * pw_sat(k,j); % תΪ��Ũ��
        end
    end
    eval(['ch4_column_model',files_sat(i).name(5:8),'= sum(ch4_slip_model,1);']); % ÿ����۲���ģʽ������Ũ��
    ch4_column_model = sum(ch4_slip_model,1);
    % ����--ģʽ���ݱȽ�
    RMSe6(i,1) = sqrt(sum((ch4_column_model - xch4_sat').^2)/length(xch4_sat));  %RMSE�����������ݵĲ���
    temp_model = [temp_model;ch4_column_model'];
    temp_sat = [temp_sat;xch4_sat];
    clear position_mark ch4_slip_model;
end
ave_model6 = mean(temp_model);
ave_sat6 = mean(temp_sat);
rmse = [mean(RMSe1);mean(RMSe2);mean(RMSe3);mean(RMSe4);mean(RMSe5);mean(RMSe6)];
disp('������ϣ�����')
figure(2)
ave_model = [ave_model1,ave_model2,ave_model3,ave_model4,ave_model5,ave_model6];
ave_sat = [ave_sat1,ave_sat2,ave_sat3,ave_sat4,ave_sat5,ave_sat6];
plot(1:6,ave_model,'r-');
hold on
plot(1:6,ave_sat,'b-');

