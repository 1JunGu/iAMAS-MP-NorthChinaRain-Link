undef("processing_lon_rainfall")
procedure processing_lon_rainfall(data_path:string, index_region:numeric, lonCell_region:numeric, lon_interval:numeric, rain_region_lon:numeric)
local rain_fi, rain, rain_region
begin
    rain_fi = addfile(data_path + "rain_mpas.nc","r")
    rain = rain_fi->rain_3day
    rain_region = rain(index_region)

    nlon = dimsizes(rain_region_lon)
    do i = 0, nlon - 1
        index_lon := ind(lonCell_region.ge.lon_interval(i)-0.25.and.lonCell_region.le.lon_interval(i)+0.25)
        rain_region_lon(i) = dim_avg_n_Wrap(rain_region(index_lon), 0)
    end do

end

begin
    dq = str_get_dq()
    date_cmd   = "date +" + dq + "%a %b %d %H:%M:%S %Z %Y" + dq
    wcStrt = systemfunc(date_cmd)
;---Processing----------------
    ;Read mesh file
    mesh_path = "../data/simulation/cell_fill.nc"
    mesh_fi = addfile(mesh_path,"r")
    latCell = mesh_fi->latCell
    lonCell = mesh_fi->lonCell

    ;select region
    minlat = 35.
    maxlat = 41.
    minlon = 105.
    maxlon = 131

    index_region = ind(latCell.ge.minlat.and.latCell.le.maxlat.and.lonCell.ge.minlon.and.lonCell.le.maxlon)
    latCell_region = latCell(index_region)
    lonCell_region = lonCell(index_region)

    ;select lon interval
    lon_interval = fspan(105,130,51);0.5
    rain_region_lon = new((/2,51/),double)

    case_list = (/"CTL","RM_T_MP"/)
    data_path = "/work/home/jungu/Work/iAMAS-237-Rainstorm-paper/data/simulation/0728_12/" + case_list + "/"
    processing_lon_rainfall(data_path(0), index_region, lonCell_region, lon_interval, rain_region_lon(0,:))
    processing_lon_rainfall(data_path(1), index_region, lonCell_region, lon_interval, rain_region_lon(1,:))

    ;member processing
    rain_region_lon_ctl_member = new((/7,51/),double)
    rain_region_lon_rm_t_mp_member = new((/7,51/),double)
    member_list = (/"0728_09","0728_10","0728_11","0728_12","0728_13","0728_14","0728_15"/)
    data_path_ctl = "/work/jungu/iAMAS-237-Rainstorm-paper/data/simulation/0728_12/" + case_list(0) + "/member/" \
        + member_list + "/3day/"
    data_path_rm_t_mp = "/work/jungu/iAMAS-237-Rainstorm-paper/data/simulation/0728_12/" + case_list(1) + "/member/" \
        + member_list + "/3day/"
    do imember = 0, 6
        processing_lon_rainfall(data_path_ctl(imember), index_region, lonCell_region, lon_interval, rain_region_lon_ctl_member(imember,:))
        processing_lon_rainfall(data_path_rm_t_mp(imember), index_region, lonCell_region, lon_interval, rain_region_lon_rm_t_mp_member(imember,:))
    end do

    ;the border of the ensemble member
    rain_3day_ctl_xp = fspan(105.0, 130.0, 102)
    rain_3day_ctl_yp = new(102,double)
    ;rain_3day_rm_t_mp_xp = new(102,double) ;share same x-axis with control case
    rain_3day_rm_t_mp_yp = new(102,double)
    do i = 0, 50
        rain_3day_ctl_yp(i) = min(rain_region_lon_ctl_member(:,i))
        rain_3day_ctl_yp(101 -i) = max(rain_region_lon_ctl_member(:,i))

        rain_3day_rm_t_mp_yp(i) = min(rain_region_lon_rm_t_mp_member(:,i))
        rain_3day_rm_t_mp_yp(101 -i) = max(rain_region_lon_rm_t_mp_member(:,i))
    end do
    
    ;icase = 0
    ;rain_ctl_fi = addfile(data_path(icase) + "rain_mpas.nc","r")
    ;rain_ctl = rain_ctl_fi->rain_3day
    ;rain_ctl_region = rain_ctl(index_region)

    ;icase = 1
    ;rain_RM_T_MP_fi = addfile(data_path(icase) + "rain_mpas.nc","r")
    ;rain_RM_T_MP = rain_RM_T_MP_fi->rain_3day
    ;rain_RM_T_MP_region = rain_RM_T_MP(index_region)

    ;do i = 0, 50
    ;    index_lon := ind(lonCell_region.ge.lon_interval(i)-0.25.and.lonCell_region.le.lon_interval(i)+0.25)
    ;    rain_region_lon(0,i) = dim_avg_n_Wrap(rain_ctl_region(index_lon), 0)
    ;    ;rain_region_lon(1,i) = dim_avg_n_Wrap(rain_RM_T_region(index_lon), 0)
    ;    rain_region_lon(1,i) = dim_avg_n_Wrap(rain_RM_T_MP_region(index_lon), 0)
    ;end do
    ;printMinMax(rain_region_lon, 1)
    ;exit
    ;printMinMax(rain_region_lon, 1)
    
;-----------------------------
    wallClockElapseTime(wcStrt, "Processing", 0)
    wcStrtGraphics = systemfunc(date_cmd)
;---Graphics------------------
    wks_name = "Figure3b"
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
    res@gsnStringFont = 26
    res@gsnStringFontHeightF = 0.03
    ;res@gsnLeftString = "(b) Longitude distribution of rainfall"
    res@gsnLeftString = ""
    res@gsnRightString= ""
    res@gsnLeftStringOrthogonalPosF = 0.00

    ;set uniform resources
    xyres = res
    xyres@vpHeightF = 0.55
    xyres@vpWidthF  = 0.6

    xyres@xyLineThicknessF = 11 * N_res
    xyres@xyMonoDashPattern = True
    colors = (/"Violetred","dodgerblue"/)
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
    xyres@trYMaxF = 316.
    xyres@trXMinF = 109
    xyres@trXMaxF = 123
    xyres@tmXTOn = False
    xyres@tmYROn = False
    xyres@tmXBMode = "Explicit"
    xyres@tmXBValues = fspan(105,130,6)
    xyres@tmXBLabels = "~F25~"+xyres@tmXBValues + "~S~o~N~E"
    xyres@tmXBMinorValues = fspan(105,130,51)
    xyres@tmXBLabelFontHeightF = 0.017
    xyres@tmYLMode = "Explicit"
    xyres@tmYLValues = fspan(0,300,7)
    xyres@tmYLLabels = "~F25~"+xyres@tmYLValues
    xyres@tmYLMinorValues = fspan(0,320,33)
    xyres@tmYLLabelFontHeightF = 0.017


    xyres@pmLegendDisplayMode = "Always"
    xyres@pmLegendHeightF = 0.12
    xyres@pmLegendWidthF = 0.12
    xyres@pmLegendSide   = "Top"
    xyres@pmLegendOrthogonalPosF = -0.3
    xyres@pmLegendParallelPosF   = 0.8
    xyres@lgLabelFontHeightF = 0.018
    xyres@lgPerimOn = False
    xyres@lgItemOrder = (/1,0/)
    xyres@xyExplicitLegendLabels = "~F25~" + (/"   CTL ","   RM_T_MP "/)
    xyres@lgBoxMinorExtentF = 0.3

    plot = gsn_csm_xy(wks,lon_interval,rain_region_lon,xyres)

    ;add polygon
    plres =  True
    plres@tfPolyDrawOrder  = "Predraw"
    plres@gsFillOpacityF = 0.2
    plres@gsFillColor = colors(0)
    dum11 = gsn_add_polygon(wks, plot, rain_3day_ctl_xp, rain_3day_ctl_yp, plres)
    plres@gsFillColor = colors(1)
    dum22 = gsn_add_polygon(wks, plot, rain_3day_ctl_xp, rain_3day_rm_t_mp_yp, plres)


    lnres = True
    lnres@gsLineDashPattern = 11
    lnres@gsLineThicknessF = 4.5*N_res
    lnres@tfPolyDrawOrder = "PostDraw"
    lnres@gsLineColor = "violetred"
    mkres = True
    mkres@gsMarkerColor = "dodgerblue"
    mkres@tfPolyDrawOrder = "PreDraw"
    mkres@gsMarkerIndex = 16
    mkres@gsMarkerSizeF = 0.01
    mkres@gsMarkerThicknessF = 4.5*N_res
    anno_11 = gsn_add_polyline(wks, plot, (/114,114/), (/0,320/), lnres)
    ;anno_12 = gsn_add_polyline(wks, plot_xy, (/10,34/), (/(PDF_array(3,9) + PDF_array(3,10))/2.,(PDF_array(3,9)+PDF_array(3,10))/2./), lnres)
    ;anno_13 = gsn_add_polymarker(wks, plot_xy, 10, (PDF_array(3,9) + PDF_array(3,10))/2., mkres)
    lnres@gsLineColor = colors(1)
    mkres@gsMarkerColor = "goldenrod"
    anno_21 = gsn_add_polyline(wks, plot, (/115.5,115.5/), (/0,320/), lnres)
    ;anno_22 = gsn_add_polyline(wks, plot_xy, (/22.5,34/), (/PDF_array(2,22),PDF_array(2,22)/), lnres)
    ;anno_23 = gsn_add_polymarker(wks, plot_xy, 22.5, PDF_array(2,22), mkres)

    plres =  True
    plres@tfPolyDrawOrder  = "Predraw"
    plres@gsFillOpacityF = 0.17
    plres@gsFillColor = "dimgray"
    ;dum = gsn_add_polygon(wks, plot, (/113.8,113.8,115.5,115.5,113.8/), (/0,310,310,0,0/), plres)
    dum = gsn_add_polygon(wks, plot, (/114,114,115.5,115.5,114/), (/0,320,320,0,0/), plres)

    draw(plot)
    frame(wks)
    
;-----------------------------
    wallClockElapseTime(wcStrtGraphics, "Graphics", 0)
    wallClockElapseTime(wcStrt, "Processing and Graphics", 0)
end
