undef("read_series")
procedure read_series(path:string,exp_name:string,xp:numeric,yp:numeric)
local series_array
begin
    print("read " + path)
    series_1 = asciiread(path + "/" + exp_name + "_0728_09_series.txt", -1, "double")
    series_2 = asciiread(path + "/" + exp_name + "_0728_10_series.txt", -1, "double")
    series_3 = asciiread(path + "/" + exp_name + "_0728_11_series.txt", -1, "double")
    series_4 = asciiread(path + "/" + exp_name + "_0728_12_series.txt", -1, "double")
    series_5 = asciiread(path + "/" + exp_name + "_0728_13_series.txt", -1, "double")
    series_6 = asciiread(path + "/" + exp_name + "_0728_14_series.txt", -1, "double")
    series_7 = asciiread(path + "/" + exp_name + "_0728_15_series.txt", -1, "double")

    series_array = new((/7,72/),"double")

    series_array(0,:) = series_1
    series_array(1,:) = series_2
    series_array(2,:) = series_3
    series_array(3,:) = series_4
    series_array(4,:) = series_5
    series_array(5,:) = series_6
    series_array(6,:) = series_7

    xp =  new(144,double)
    yp =  new(144,double)
    do i =0, 71
        xp(i)     = i + 1
        xp(143-i) = i + 1
        yp(i)     = min(series_array(:,i))
        yp(143-i) = max(series_array(:,i))
    end do
    delete([/series_array/])
end

begin
    rain_3day_obs = asciiread("../../data/Figure3/rainfall/CLDAS_series.txt",-1,"double")

    data_path = "/work/home/jungu/Work/iAMAS-237-Rainstorm-paper/data/"
    rain_3day_obs = asciiread(data_path + "CLDAS/CLDAS_series.txt",-1,"double")
    rain_3day_CTL = asciiread(data_path + "simulation/0728_12/CTL/rainfall_series/CTL_ensemble_0728_12_series.txt", -1, "double")
    rain_3day_RM_T_MP = asciiread(data_path + "simulation/0728_12/RM_T_MP/rainfall_series/RM_T_MP_ensemble_0728_12_series.txt", -1, "double")
    rain_3day_RM_THQ = asciiread(data_path + "simulation/0728_12/RM_THQ/rainfall_series/RM_THQ_ensemble_0728_12_series.txt", -1, "double")
    rain_3day_RM_T = asciiread(data_path + "simulation/0728_12/RM_T/rainfall_series/RM_T_ensemble_0728_12_series.txt", -1, "double")
    rain_3day_RM_Q = asciiread(data_path + "simulation/0728_12/RM_Q/rainfall_series/RM_Q_ensemble_0728_12_series.txt", -1, "double")

    rain_3day_array = new((/3,72/),"double")
    rain_3day_array(0,:) = rain_3day_obs
    rain_3day_array(1,:) = rain_3day_CTL
    rain_3day_array(2,:) = rain_3day_RM_THQ
    ;convert cumulative array to individual array
    rain_3day_obs_hour = rain_3day_obs
    rain_3day_obs_hour(1:71) = rain_3day_obs(1:71) - rain_3day_obs(0:70)
    rain_3day_CTL_hour = rain_3day_CTL
    rain_3day_CTL_hour(1:71) = rain_3day_CTL(1:71) - rain_3day_CTL(0:70)
    rain_3day_RM_THQ_hour = rain_3day_RM_THQ
    rain_3day_RM_THQ_hour(1:71) = rain_3day_RM_THQ(1:71) - rain_3day_RM_THQ(0:70)

    rain_3day_CTL_xp =  new(144,double)
    rain_3day_CTL_yp =  new(144,double)
    read_series(data_path + "/simulation/0728_12/CTL/rainfall_series/","CTL",rain_3day_CTL_xp,rain_3day_CTL_yp)

    rain_3day_RM_THQ_xp =  new(144,double)
    rain_3day_RM_THQ_yp =  new(144,double)
    read_series(data_path + "/simulation/0728_12/RM_THQ/rainfall_series/","RM_THQ",rain_3day_RM_THQ_xp,rain_3day_RM_THQ_yp)

    N_res = 2
    wks_type = "png"
    wks_type@wkWidth  = 1024*N_res;
    wks_type@wkHeight = 1024*N_res
    wks = gsn_open_wks(wks_type, "./FigureS4a")

    res = True
    res@vpWidthF = 0.7
    res@vpHeightF = 0.64
    res@vpXF = 0.15
    res@vpYF = 0.9
    res@gsnDraw = False
    res@gsnFrame= False
    res@gsnMaximize  = False
    res@gsnLeftStringFontHeightF = 0.018
    res@gsnRightString  = ""
    res@gsnStringFont = 25
    res@tiMainString =  ""

    res@tmXTOn = False
    ;res@tmYROn = False

    res@tmBorderThicknessF = 4.5*N_res
    res@tmYLMajorThicknessF = 3.5*N_res
    res@tmYLMinorThicknessF = 3.5*N_res
    res@tmYLMajorLengthF    = 0.01
    res@tmYLMajorOutwardLengthF = 0.01
    res@tmYLMinorLengthF    = 0.005
    res@tmYLMinorOutwardLengthF = 0.005
    res@tmYRMajorThicknessF = 3.5*N_res
    res@tmYRMinorThicknessF = 3.5*N_res
    res@tmYRMajorLengthF    = 0.01
    res@tmYRMajorOutwardLengthF = 0.01
    res@tmYRMinorLengthF    = 0.005
    res@tmYRMinorOutwardLengthF = 0.005
    res@tmXBMajorThicknessF = 3.5*N_res
    res@tmXBMinorThicknessF = 3.5*N_res
    res@tmXBMajorLengthF    = 0.01
    res@tmXBMajorOutwardLengthF = 0.01
    res@tmXBMinorLengthF    = 0.006
    res@tmXBMinorOutwardLengthF = 0.006

    x_lbvalues = ispan(1,72,1)
    x_labels = "~F25~" + sprinti("%02i",(/00,06,12,18,00,06,12,18,00,06,12,18,00/))
    res@tmXBOn   = True
    res@tmXBMode = "Explicit"
    ;res@tmXBLabels = sprinti("%2i", x_labels)
    res@tmXBLabels = x_labels
    res@tmXBValues = x_lbvalues(::6)
    res@tmXBMinorValues = x_lbvalues
    res@tmXBLabelFont = 25
    res@tmYLLabelFont = 25
    res@tmLabelAutoStride = True;nice stride on labels
    res@tmXBLabelFontAspectF = 1.3125
    res@tmXBLabelFontHeightF = 0.016
    res@trXMinF = -0.5
    res@trXMaxF = 73.5

    bres = res
    bres@gsnLeftString = "~F26~a "
    bres@gsnLeftStringOrthogonalPosF = 0.005
    bres@gsnYRefLine           = 0.;very important for xyline colors
    bres@xyLineColor = "violetred" ;
    bres@xyLineThicknesses = 4.0
    bres@gsnXYBarChart = True
    bres@gsnXYBarChartBarWidth = 0.6
    ;bres@gsnXYBarChartColors = "dodgerblue"
    bres@gsnXYBarChartPatterns = -1
    ;bres@gsnXYBarChartFillLineThicknessF = 1
    ;bres@gsnXYBarChartFillOpacityF = 0.1
    ;bres@gsnXYBarChartOutlineOnly = True
    bres@gsnXYBarChartOutlineThicknessF = 0
    bres@tmYROn = False
    bres@tmYLLabelsOn = True
    bres@tmYLOn   = True
    bres@tmYLMode = "Explicit"
    bres@tmYLValues = ispan(0,6,1)
    bres@tmYLMinorValues = fspan(0,6,31)
    bres@tmYLLabels = "~F25~" + bres@tmYLValues
    bres@trYMinF = 0
    bres@trYMaxF = 5.9

    bres@tiYAxisString = "~F25~Hourly precipitation (mm/h)"
    bres@tiYAxisSide ="Left"
    bres@tiYAxisFontHeightF = 0.018

    time_series  = x_lbvalues

    xyres = res
    ;xyres@tmYUseLeft = False
    xyres@tmYLOn = False
    xyres@tmYRLabelFont = 25
    xyres@tmYROn = True
    xyres@tmYRLabelsOn = True

    xyres@trYMaxF = 165

    xyres@tiYAxisString = "~F25~Accumulated precipitation (mm)"
    xyres@tiYAxisSide ="Right"
    xyres@tiYAxisFontHeightF = 0.018

    ;colors = (/"Black","Violetred","dodgerblue","goldenrod","forestgreen","turquoise","darkslateblue"/)
    colors = (/"Black","violetred","forestgreen"/)
    xyres@xyDashPatterns  = (/0,0,0,0,0,0,0/) ; Make curves all solid except offical forecast
    xyres@xyMarkLineMode = "Lines"
    xyres@xyMarkers      = (/16,16,16,16,16,16,16/)
    xyres@xyMarkerColors = colors
    xyres@xyLineThicknesses = (/6.5,6.5,6.5,6.5,6.5,6.5,6.5/)*N_res
    xyres@xyLineColors   = colors

    plot_xy = gsn_csm_xy2(wks,time_series,rain_3day_CTL_hour,rain_3day_array,bres,xyres)
    bres1 = bres
    bres1@xyLineColor = "Black"
    plot_b1 = gsn_csm_xy(wks,time_series+0.01,rain_3day_obs_hour,bres1)
    bres1@xyLineColor = "forestgreen"
    plot_b2 = gsn_csm_xy(wks,time_series+0.02,rain_3day_RM_THQ_hour,bres1)
    anno_id2 = gsn_add_annotation(plot_xy, plot_b2, False)
    anno_id1 = gsn_add_annotation(plot_xy, plot_b1, False)


    ;overlay(plot_xy,plot_bobs)
    ;add date labels
    labels = (/"29 July","30 July","31 July"/)

    txres = True
    txres@txFont                 = 25      ;-- fill color
    txres@txFontColor            =  "Black"         ;-- set opacity of polygon
    txres@txFontHeightF          = 0.02
    txres@txJust                 = "CenterCenter"

    x_label_0 = 0.5 - ((24./74)*0.7)
    x_label_1 = 0.5
    x_label_2 = 0.5 + ((24./74)*0.7)
    y_label = 0.38 - 0.19
    gsn_text_ndc(wks,labels(0), x_label_0 , y_label ,txres)
    gsn_text_ndc(wks,labels(1), x_label_1 , y_label ,txres)
    gsn_text_ndc(wks,labels(2), x_label_2 , y_label ,txres)
    ;add polygon
    plres =  True
    plres@tfPolyDrawOrder  = "Predraw"
    plres@gsFillOpacityF = 0.2
    plres@gsFillColor = colors(1)
    dum = gsn_add_polygon(wks, plot_xy@xy2, rain_3day_CTL_xp, rain_3day_CTL_yp, plres)
    plres@gsFillColor = colors(2)
    dum2 = gsn_add_polygon(wks, plot_xy@xy2, rain_3day_RM_THQ_xp, rain_3day_RM_THQ_yp, plres)

    gres = True
    gres@YPosPercent = 85.               ; expressed as %, 0->100, sets position of bottom border of legend
                                        ;  when gres@Position="Bottom" (Default = 95.)
    gres@XPosPercent = 20.               ; expressed as %, 0->100, sets position of left border of legend
                                        ;  (Default = 5.)
    gres@Position = "Top"            ; YPosPercent setting reflects the "Top" or "Bottom" of legend
                                        ;  (Default="Top")
    gres@ItemSpacePercent = 3.          ; expressed as %, 0->100, space between legend items (Default = 2.5)
    gres@LineLabelWhiteSpacePercent = 2 ; expressed as %, 0->100, space between line and label (Default = 3.)

    lineres = True
    lineres@lgLineColors = colors
    ;lineres@lgLineOpacity = (/0.3/)              ; line opacities
    lineres@lgLineThicknesses = (/8,8,8/)*N_res
    lineres@lgDashIndexes = (/0,0,0/)                   ; line types
    lineres@LineLengthPercent = 5                        ; expressed as %, 0->100, length of line

    textres = True
    textres@lgLabels ="~F25~" +  (/"OBS","CTL","RM_THQ"/) ; labels (req)
    textres@lgLabelFontHeights = (/0.015/)                           ; label font heights
    textres@lgLabelColors = colors
    ;textres@lgLabelOpacity = (/0.8/)                                     ; 0->1, label opacities
    simple_legend_ndc(wks,gres,lineres,textres)


    ;overlay(plot_bobs,plot_xy)
    draw(plot_xy)
    ;drawNDCGrid(wks)
    frame(wks)

end
