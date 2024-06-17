begin
    dq = str_get_dq()
    date_cmd   = "date +" + dq + "%a %b %d %H:%M:%S %Z %Y" + dq
    wcStrt = systemfunc(date_cmd)
;---Processing----------------
    case_list = (/"CTL","RM_THQ","RM_TH","RM_Q","RM_T","RM_T_NO_MP"/)

;---read observation 
    data_path = "../data/Figure2/rainfall/"
    obs_fi = addfile(data_path + "CLDAS_Doksuri.nc" ,"r")
    rain_obs = obs_fi->rain_3day
    lat_obs  = obs_fi->LAT
    lon_obs  = obs_fi->LON
;---read simulations 
    rain_sim = new((/6,785410/),double)
    case_list = (/"CTL","RM_THQ","RM_Q","RM_TH","RM_T","RM_T_NO_MP"/)
    do icase = 0, 5
        fi_rainc = addfile(data_path + case_list(icase) +  "/rainc_hr.nc","r")
        rainc_hr = fi_rainc->rainc_hr
        fi_rainnc = addfile(data_path + case_list(icase) +  "/rainnc_hr.nc","r")
        rainnc_hr = fi_rainnc->rainnc_hr
        rain_sim(icase,:) = (rainc_hr + rainnc_hr)*72
    end do

    mesh_path = "/storage/aemolcore02/jungu/mesh/rotated_4-60km_28N117E_785410/init_static.nc"
    r2d = get_r2d("double")
    mesh_fi = addfile(mesh_path,"r")
    latCell = mesh_fi->latCell*r2d
    lonCell = mesh_fi->lonCell*r2d
    areaCell = mesh_fi->areaCell
    ;printMinMax(areaCell,1)
    ;printVarSummary(areaCell)

    ;select region
    minlat = 35.
    maxlat = 43.
    minlon = 105.
    maxlon = 130
    ;obs region
    rain_obs_region = rain_obs({minlat:maxlat},{minlon:maxlon})
    lat_obs_region = lat_obs({minlat:maxlat})
    lon_obs_region = lon_obs({minlon:maxlon})

    re   = 6.37122e06
    rad  = 4.0 * atan(1.0) / 180.0
    con  = re * rad
    clat = cos(lat_obs_region * rad)           ; cosine of latitude

    dlon = (lon_obs_region(2) - lon_obs_region(1))        ; assume dlon is constant
    dlat = (lat_obs_region(2) - lat_obs_region(1))        ; assume dlat is constant

    dx   = con * dlon * clat        ; dx at each latitude
    dy   = con * dlat               ; dy is constant
    dydx = tofloat(dy * dx)                  ; dydx(nlat)

    wgt  = new((/dimsizes(lat_obs_region), dimsizes(lon_obs_region)/), typeof(rain_obs_region))
    wgt  = conform(wgt, dydx, 0)
    wgt!0 = "lat"
    wgt!1 = "lon"
    wgt&lat = lat_obs_region
    wgt&lon = lon_obs_region

    ;sim region
    index_region = ind(latCell.ge.minlat.and.latCell.le.maxlat.and.lonCell.ge.minlon.and.lonCell.le.maxlon)
    latCell_region = latCell(index_region)
    lonCell_region = lonCell(index_region)
    area_region    = areaCell(index_region)
    rain_sim_region = rain_sim(:,index_region)

    area_rain = new((/4,7/),double)
    ;obs
    rain_obs_50mm = where(rain_obs_region.ge.50,1.,0.)
    area_rain(0,0) = wgt_areasum2(rain_obs_50mm, wgt, 0)
    rain_obs_100mm = where(rain_obs_region.ge.100,1.,0.)
    area_rain(1,0) = wgt_areasum2(rain_obs_100mm, wgt, 0)
    rain_obs_200mm = where(rain_obs_region.ge.200,1.,0.)
    area_rain(2,0) = wgt_areasum2(rain_obs_200mm, wgt, 0)
    rain_obs_400mm = where(rain_obs_region.ge.400,1.,0.)
    area_rain(3,0) = wgt_areasum2(rain_obs_400mm, wgt, 0)
    ;sim
    do icase = 0, 5
        rain_sim_50mm = where(rain_sim_region(icase,:).ge.50,1.,0.)
        area_rain(0,icase+1) = dim_sum_wgt_n_Wrap(rain_sim_50mm, area_region, 1, 0)
        rain_sim_100mm = where(rain_sim_region(icase,:).ge.100,1.,0.)
        area_rain(1,icase+1) = dim_sum_wgt_n_Wrap(rain_sim_100mm, area_region, 1, 0)
        rain_sim_200mm = where(rain_sim_region(icase,:).ge.200,1.,0.)
        area_rain(2,icase+1) = dim_sum_wgt_n_Wrap(rain_sim_200mm, area_region, 1, 0)
        rain_sim_400mm = where(rain_sim_region(icase,:).ge.400,1.,0.)
        area_rain(3,icase+1) = dim_sum_wgt_n_Wrap(rain_sim_400mm, area_region, 1, 0)
    end do
    area_rain = area_rain/1e9
    
;-----------------------------
    wallClockElapseTime(wcStrt, "Processing", 0)
    wcStrtGraphics = systemfunc(date_cmd)
;---Graphics------------------
    wks_name = "Figure3f"
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
    res@gsnLeftStringOrthogonalPosF = 0.01

    ;set uniform resources
    xyres = res
    xyres@vpHeightF = 0.233
    xyres@vpWidthF  = 0.8

    xyres@xyLineThicknessF = 0.1 * N_res
    xyres@xyMonoDashPattern = True
    ;xyres@xyMarkLineMode = "Lines"
    xyres@gsnXYBarChart = True
    xyres@gsnXYBarChartBarWidth = 0.3
    xyres@gsnXYBarChartPatterns = 0
    ;xyres@gsnXYBarChartFillLineThicknessF = 1
    ;xyres@gsnXYBarChartFillOpacityF = 0.1
    ;xyres@gsnXYBarChartOutlineOnly = True
    xyres@gsnXYBarChartOutlineThicknessF = 0
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
    xyres@tmYRMajorThicknessF = 3.5*N_res
    xyres@tmYRMinorThicknessF = 3.5*N_res
    xyres@tmYRMajorLengthF    = 0.01
    xyres@tmYRMajorOutwardLengthF = 0.01
    xyres@tmYRMinorLengthF    = 0.005
    xyres@tmYRMinorOutwardLengthF = 0.005
    xyres@tmXBMajorThicknessF = 3.5*N_res
    xyres@tmXBMinorThicknessF = 3.5*N_res
    xyres@tmXBMajorLengthF    = 0.01
    xyres@tmXBMajorOutwardLengthF = 0.01
    xyres@tmXBMinorLengthF    = 0.006
    xyres@tmXBMinorOutwardLengthF = 0.006

    ;xyres@vpXF = 0.1
    ;xyres@vpYF = 0.9
    xyres@tiYAxisFontHeightF = 0.017
    xyres@trXMinF = 0.5
    xyres@trXMaxF = 7.5
    xyres@tmXTOn = False
    xyres@tmYROn = False

    xyres@tmXBMode = "Explicit"
    xyres@tmXBValues = ispan(1,7,1)
    xyres@tmXBLabels = "~F25~"+ (/"OBS","CTL","RM_THQ","RM_Q","RM_TH","RM_T","RM_T_NO_MP"/)
    xyres@tmXBLabelAngleF = 26
    xyres@tmXBMinorOn = False 
    xyres@tmXBLabelFontHeightF = 0.017
    xyres@tmYLLabelFontHeightF = 0.017
    xyres@tmYRLabelFontHeightF = 0.017

    colors = new((/7/),string)
    colors = (/"Black","Violetred","dodgerblue","goldenrod","forestgreen","turquoise","darkslateblue"/)
    xyres@gsnXYBarChartColors = colors
    xyres@xyLineColors = colors

    txres                     = True                 ; text mods desired
    txres@txFontColor         = "Black"
    txres@txFontHeightF       = 0.013                ; default size is HUGE!
    txres@txAngleF            = 0.                  ; text angle
    txres@txJust              = "CenterCenter"         ; puts text on top of bars
    txres@txFont   = 25

    plres =  True
    plres@tfPolyDrawOrder  = "PostDraw"
    plres@gsFillOpacityF = 0.2
    plres@gsFillColor = "dimgray"

    xyres1 = xyres
    xyres1@gsnLeftString = "(f) Rainfall area above 100/200/400 mm (10~S~3~N~ km~S~2~N~)"
    xyres1@trYMinF = 80
    xyres1@trYMaxF = 320
    ;xyres1@xyYStyle = "Log"
    xyres1@tmYLMode = "Explicit"
    xyres1@tmYLValues = fspan(100,300,5)
    xyres1@tmYLMinorValues = fspan(100,300,21)
    xyres1@tmYLLabels = "~F25~"+xyres1@tmYLValues
    xyres1@tmXBBorderOn = False
    xyres1@tiYAxisString = "~F25~> 100 mm"
    plot1 = gsn_csm_xy(wks,ispan(1,7,1),area_rain(1,:),xyres1)

    do n = 0,6
       plot1@$unique_string(n)$= gsn_add_text(wks,plot1,sprintf("%3.1f",area_rain(1,n)),n+1,area_rain(1,n)+ 12,txres) ; add labels
    end do
    yp_min = xyres1@trYMinF
    yp_max = xyres1@trYMaxF
    margin = 0.3
    xp_min = 3 - margin
    xp_max = 3 + margin
    dum11 = gsn_add_polygon(wks, plot1, (/xp_min,xp_max,xp_max,xp_min,xp_min/), (/yp_min,yp_min,yp_max,yp_max,yp_min/), plres)
    xp_min = 5 - margin
    xp_max = 6 + margin
    dum12 = gsn_add_polygon(wks, plot1, (/xp_min,xp_max,xp_max,xp_min,xp_min/), (/yp_min,yp_min,yp_max,yp_max,yp_min/), plres)

    xyres2 = xyres
    xyres2@trYMinF = 45
    xyres2@trYMaxF = 105
    xyres2@tmYLOn = False
    xyres2@tmYUseLeft = False
    xyres2@tmYROn = True
    xyres2@tmYRLabelsOn = True
    xyres2@tmYRMode = "Explicit"
    xyres2@tmYRValues = fspan(50,100,6)
    xyres2@tmYRMinorValues = fspan(50,100,11)
    xyres2@tmYRLabelFont = 25
    xyres2@tmYRLabels = xyres2@tmYRValues
    ;xyres2@tmXBBorderOn = False
    ;xyres2@tmXTBorderOn = False
    xyres2@tiYAxisString = "~F25~> 200 mm"
    xyres2@tiYAxisSide ="Right"
    plot2 = gsn_csm_xy(wks,ispan(1,7,1),area_rain(2,:),xyres2)

    do n = 0,6
       plot2@$unique_string(n)$= gsn_add_text(wks,plot2,sprintf("%3.1f",area_rain(2,n)),n+1,area_rain(2,n)+ 3,txres) ; add labels
    end do

    yp_min = xyres2@trYMinF
    yp_max = xyres2@trYMaxF
    xp_min = 3 - margin
    xp_max = 3 + margin
    dum21 = gsn_add_polygon(wks, plot2, (/xp_min,xp_max,xp_max,xp_min,xp_min/), (/yp_min,yp_min,yp_max,yp_max,yp_min/), plres)
    xp_min = 5 - margin
    xp_max = 6 + margin
    dum22 = gsn_add_polygon(wks, plot2, (/xp_min,xp_max,xp_max,xp_min,xp_min/), (/yp_min,yp_min,yp_max,yp_max,yp_min/), plres)

    xyres3 = xyres
    xyres3@trYMinF = 0.3
    xyres3@trYMaxF = 30
    xyres3@xyYStyle = "Log"
    xyres3@tmYLMode = "Explicit"
    xyres3@tmYLValues = (/0.5,1,2,4,8,16/)
    xyres3@tmYLLabels = "~F25~"+xyres3@tmYLValues
    xyres3@tmXTBorderOn = False
    xyres3@tiYAxisString = "~F25~> 400 mm"
    plot3 = gsn_csm_xy(wks,ispan(1,7,1),area_rain(3,:),xyres3)

    do n = 0,6
       plot3@$unique_string(n)$= gsn_add_text(wks,plot3,sprintf("%3.1f",area_rain(3,n)),n+1,area_rain(3,n)*1.2,txres) ; add labels
    end do

    yp_min := xyres3@trYMinF
    yp_max := xyres3@trYMaxF
    xp_min = 3 - margin
    xp_max = 3 + margin
    dum31 = gsn_add_polygon(wks, plot3, (/xp_min,xp_max,xp_max,xp_min,xp_min/), (/yp_min,yp_min,yp_max,yp_max,yp_min/), plres)
    xp_min = 5 - margin
    xp_max = 6 + margin
    dum32 = gsn_add_polygon(wks, plot3, (/xp_min,xp_max,xp_max,xp_min,xp_min/), (/yp_min,yp_min,yp_max,yp_max,yp_min/), plres)
    ;xyres@pmLegendDisplayMode = "Always"
    ;xyres@pmLegendHeightF = 0.15
    ;xyres@pmLegendWidthF = 0.12
    ;xyres@pmLegendSide   = "Top"
    ;xyres@pmLegendOrthogonalPosF = -0.3
    ;xyres@pmLegendParallelPosF   = 0.15
    ;xyres@lgLabelFontHeightF = 0.016
    ;xyres@lgPerimOn = False
    ;xyres@lgItemOrder = (/2,1,0/)
    ;;xyres@xyExplicitLegendLabels = "~F25~" + (/"   CTL ","   RM_THQ ","   RM_TH ","   RM_Q ", "   RM_T ", "   RM_T_NO_MP "/)
    ;xyres@xyExplicitLegendLabels = "~F25~" + (/"   100 mm ","   200 mm ","   400 mm "/)
    ;xyres@lgBoxMinorExtentF = 0.3
    res1 = True
    res2 = True
    res1@gsnMaximize = True
    res1@gsnAttachBorderOn = False
    res2@gsnAttachPlotsXAxis = True
    ;res2@gsnAttachBorderOn = False
    amid = gsn_attach_plots(plot1, (/plot2,plot3/), res1, res2)


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

    draw(plot1)
    frame(wks)
    
;-----------------------------
    wallClockElapseTime(wcStrtGraphics, "Graphics", 0)
    wallClockElapseTime(wcStrt, "Processing and Graphics", 0)
end
