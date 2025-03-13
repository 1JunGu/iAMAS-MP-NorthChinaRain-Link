begin
    dq = str_get_dq()
    date_cmd   = "date +" + dq + "%a %b %d %H:%M:%S %Z %Y" + dq
    wcStrt = systemfunc(date_cmd)
;---Processing----------------

    rain_sim = new((/4,785410/),double)
    ;case_list = (/"CTL","RM_THQ","RM_Q","RM_TH","RM_T_NO_MP","RM_T"/)
    data_path = "../../data/simulation/0728_12/"
    case_list = (/"CTL","RM_THQ","RM_Q","RM_T"/)
    do icase = 0, 0
        fi_rain = addfile(data_path + case_list(icase) +  "/rain_mpas.nc","r")
        rain_sim(icase,:) = fi_rain->rain_3day
    end do
    do icase = 1, 3
        fi_rain = addfile(data_path + case_list(icase) +  "/rain_hr.nc","r")
        rain_sim(icase,:) = fi_rain->rain_hr*72
    end do

    mesh_path = "../../data/simulation/cell_fill.nc"
    mesh_fi = addfile(mesh_path,"r")
    latCell = mesh_fi->latCell
    lonCell = mesh_fi->lonCell

    ;select region
    minlat = 35.
    maxlat = 43.
    minlon = 105.
    maxlon = 130


    index_region = ind(latCell.ge.minlat.and.latCell.le.maxlat.and.lonCell.ge.minlon.and.lonCell.le.maxlon)
    latCell_region = latCell(index_region)
    lonCell_region = lonCell(index_region)
    rain_sim_region = rain_sim(:,index_region)


    lon_interval = fspan(105,130,51);0.5
    rain_region_lon = new((/4,51/),double)
    do i = 0, 50
        index_lon := ind(lonCell_region.ge.lon_interval(i)-0.25.and.lonCell_region.le.lon_interval(i)+0.25)
        rain_region_lon(0,i) = dim_avg_n_Wrap(rain_sim_region(0,index_lon), 0)
        rain_region_lon(1,i) = dim_avg_n_Wrap(rain_sim_region(2,index_lon), 0)
        rain_region_lon(2,i) = dim_avg_n_Wrap(rain_sim_region(1,index_lon), 0)
        rain_region_lon(3,i) = dim_avg_n_Wrap(rain_sim_region(3,index_lon), 0)
    end do

    printMinMax(rain_region_lon, 1)
    
;-----------------------------
    wallClockElapseTime(wcStrt, "Processing", 0)
    wcStrtGraphics = systemfunc(date_cmd)
;---Graphics------------------
    wks_name = "FigureS5"
    wks_type = "png"
    N_res = 2
    wks_type@wkHeight = 1024*N_res
    wks_type@wkWidth  = 1024*N_res
    wks = gsn_open_wks(wks_type, wks_name)

    ;set uniform resources
    res = True
    res@gsnDraw = False
    res@gsnFrame= False
    res@gsnMaximize  = False
    res@gsnStringFont = 25
    res@gsnStringFontHeightF = 0.02
    res@gsnLeftString = ""
    res@gsnRightString= ""
    res@gsnLeftStringOrthogonalPosF = 0.00

    ;set uniform resources
    xyres = res
    xyres@vpHeightF = 0.7
    xyres@vpWidthF  = 0.8

    xyres@xyLineThicknessF = 8 * N_res
    xyres@xyMonoDashPattern = True
    colors = (/"Violetred","turquoise","forestgreen","darkslateblue"/);,"darkslateblue"/)
    xyres@xyLineColors = colors
    xyres@xyMarkLineMode = "Lines"
    ;xyres@xyMarkers      = (/1,7/)
    ;xyres@xyMarkerSizes  = (/0.02,0.005/);default 0.01
    ;xyres@xyMarkerThicknesses = (/2,8./)
   
    ;xyres@xyMarkerColors := (/"navyblue","orange"/)

    ;xyres@tmXBMajorLengthF = 0.01
    ;xyres@tmXBMinorLengthF = 0.005
    ;xyres@tmXBMajorOutwardLengthF = 0.01
    ;xyres@tmYLMajorLengthF = 0.01
    ;xyres@tmYLMinorLengthF = 0.005
    ;xyres@tmYLMajorOutwardLengthF = 0.01

    ;xyres@tmBorderThicknessF =4.5 * N_res
    ;xyres@tmXBMajorThicknessF=3.5 * N_res
    ;xyres@tmXBLabelAngleF = 0.

    xyres@tmBorderThicknessF = 4.5*N_res

    xyres@tmYLMajorThicknessF = 3.5*N_res
    xyres@tmYLMinorThicknessF = 3.5*N_res
    xyres@tmYLMajorLengthF    = 0.01
    xyres@tmYLMajorOutwardLengthF = 0.01
    xyres@tmYLMinorLengthF    = 0.005
    xyres@tmYLMinorOutwardLengthF = 0.005
    xyres@tmXBMajorThicknessF = 3.5*N_res
    xyres@tmXBMinorThicknessF = 3.5*N_res
    xyres@tmXBMajorLengthF    = 0.01
    xyres@tmXBMajorOutwardLengthF = 0.01
    xyres@tmXBMinorLengthF    = 0.006
    xyres@tmXBMinorOutwardLengthF = 0.006

    xyres@vpXF = 0.1
    xyres@vpYF = 0.9
    xyres@tiYAxisString = "~F25~Rainfall (mm)"
    xyres@tiYAxisFontHeightF = 0.017
    xyres@trYMinF = 0.
    xyres@trYMaxF = 252.
    xyres@trXMinF = 109
    xyres@trXMaxF = 123
    xyres@tmXTOn = False
    xyres@tmYROn = False
    xyres@tmXBMode = "Explicit"
    xyres@tmXBValues = fspan(105,130,6)
    xyres@tmXBLabels = "~F25~"+xyres@tmXBValues + "~S~o~N~E"
    xyres@tmXBMinorValues = lon_interval
    xyres@tmXBLabelFontHeightF = 0.017
    xyres@tmYLMode = "Explicit"
    xyres@tmYLValues = fspan(0,300,7)
    xyres@tmYLLabels = "~F25~"+xyres@tmYLValues
    xyres@tmYLMinorValues = fspan(0,300,31)
    xyres@tmYLLabelFontHeightF = 0.017


    xyres@pmLegendDisplayMode = "Always"
    xyres@pmLegendHeightF = 0.15
    xyres@pmLegendWidthF = 0.12
    xyres@pmLegendSide   = "Top"
    xyres@pmLegendOrthogonalPosF = -0.3
    xyres@pmLegendParallelPosF   = 0.15
    xyres@lgLabelFontHeightF = 0.016
    xyres@lgPerimOn = False
    xyres@lgItemOrder = (/3,2,1,0/)
    xyres@xyExplicitLegendLabels = "~F25~" + (/"   CTL ","   RM_Q ","   RM_THQ ","   RM_T "/);, "   RM_T_NO_MP "/)
    xyres@lgBoxMinorExtentF = 0.3

    plot = gsn_csm_xy(wks,lon_interval,rain_region_lon,xyres)

    lnres = True
    lnres@gsLineDashPattern = 11
    lnres@gsLineThicknessF = 4.5*N_res
    lnres@tfPolyDrawOrder = "PostDraw"
    lnres@gsLineColor = "violetred"
    mkres = True
    mkres@gsMarkerColor = "forestgreen"
    mkres@tfPolyDrawOrder = "PreDraw"
    mkres@gsMarkerIndex = 16
    mkres@gsMarkerSizeF = 0.01
    mkres@gsMarkerThicknessF = 4.5*N_res
    ;anno_11 = gsn_add_polyline(wks, plot, (/114,114/), (/0,310/), lnres)
    ;anno_12 = gsn_add_polyline(wks, plot_xy, (/10,34/), (/(PDF_array(3,9) + PDF_array(3,10))/2.,(PDF_array(3,9)+PDF_array(3,10))/2./), lnres)
    ;anno_13 = gsn_add_polymarker(wks, plot_xy, 10, (PDF_array(3,9) + PDF_array(3,10))/2., mkres)
    lnres@gsLineColor = colors(1)
    mkres@gsMarkerColor = "goldenrod"
    ;anno_21 = gsn_add_polyline(wks, plot, (/117,117/), (/0,310/), lnres)
    ;anno_22 = gsn_add_polyline(wks, plot_xy, (/22.5,34/), (/PDF_array(2,22),PDF_array(2,22)/), lnres)
    ;anno_23 = gsn_add_polymarker(wks, plot_xy, 22.5, PDF_array(2,22), mkres)

    plres =  True
    plres@tfPolyDrawOrder  = "Predraw"
    plres@gsFillOpacityF = 0.17
    plres@gsFillColor = "dimgray"
    ;dum = gsn_add_polygon(wks, plot, (/114,114,117,117,114/), (/0,310,310,0,0/), plres)

    draw(plot)
    frame(wks)
    
;-----------------------------
    wallClockElapseTime(wcStrtGraphics, "Graphics", 0)
    wallClockElapseTime(wcStrt, "Processing and Graphics", 0)
end
