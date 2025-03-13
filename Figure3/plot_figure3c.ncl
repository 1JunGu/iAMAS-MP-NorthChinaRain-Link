load "$NCL_script/boxplot_func.ncl"
undef("process_mpas_rain_area")
procedure process_mpas_rain_area(data_path:string, var_name:string, index_region:numeric, area_region:numeric, area_rain:numeric)
local rain_fi, rain_sim, rain_sim_region
begin
    rain_fi = addfile(data_path,"r")
    rain_sim = rain_fi->$var_name$
    rain_sim_region = rain_sim(index_region)

    rain_sim_50mm = where(rain_sim_region.ge.50,1.,0.)
    area_rain(0) = dim_sum_wgt_n_Wrap(rain_sim_50mm, area_region, 1, 0)
    rain_sim_100mm = where(rain_sim_region.ge.100,1.,0.)
    area_rain(1) = dim_sum_wgt_n_Wrap(rain_sim_100mm, area_region, 1, 0)
    rain_sim_200mm = where(rain_sim_region.ge.200,1.,0.)
    area_rain(2) = dim_sum_wgt_n_Wrap(rain_sim_200mm, area_region, 1, 0)
    rain_sim_400mm = where(rain_sim_region.ge.400,1.,0.)
    area_rain(3) = dim_sum_wgt_n_Wrap(rain_sim_400mm, area_region, 1, 0)
    ;area_rain = area_rain/1e9
end
undef("gsn_add_boxplot")
procedure gsn_add_boxplot(wks:graphic, plot:graphic,xo:numeric,yo:numeric,boxWidths:numeric,polyres:logical)
local yy, xx, dum
begin
    ;max line
    yy = (/yo(4),yo(4)/)
    xx = (/(xo-(boxWidths/8.)),(xo+(boxWidths/8.))/)
    plot@$unique_string("dum")$ = gsn_add_polyline(wks,plot,xx,yy,polyres)

    ;max -- 75th percentile
    yy = (/yo(3),yo(4)/)
    xx = (/xo,xo/)
    polyres@gsLineDashPattern = 1
    ;dum(1) = gsn_add_polyline(wks,plot,xx,yy,polyres)
    plot@$unique_string("dum")$ = gsn_add_polyline(wks,plot,xx,yy,polyres)
    polyres@gsLineDashPattern = 0

    ;75th percentile
    yy = (/yo(3),yo(3)/)
    xx = (/(xo-(boxWidths/4.)),(xo+(boxWidths/4.))/)
    plot@$unique_string("dum")$ = gsn_add_polyline(wks,plot,xx,yy,polyres)

    ;left line of box
    yy = (/yo(1),yo(3)/)
    xx = (/(xo-(boxWidths/4.)),(xo-(boxWidths/4.))/)
    plot@$unique_string("dum")$ = gsn_add_polyline(wks,plot,xx,yy,polyres)

    ;median line of box
    yy = (/yo(2),yo(2)/)
    xx = (/(xo-(boxWidths/4.)),(xo+(boxWidths/4.))/)
    plot@$unique_string("dum")$ = gsn_add_polyline(wks,plot,xx,yy,polyres)

    ;right line of box
    yy = (/yo(1),yo(3)/)
    xx = (/(xo+(boxWidths/4.)),(xo+(boxWidths/4.))/)
    plot@$unique_string("dum")$ = gsn_add_polyline(wks,plot,xx,yy,polyres)

    ;25 percentile
    yy = (/yo(1),yo(1)/)
    xx = (/(xo-(boxWidths/4.)),(xo+(boxWidths/4))/)
    plot@$unique_string("dum")$ = gsn_add_polyline(wks,plot,xx,yy,polyres)

    ;25th percentile -- min
    yy = (/yo(0),yo(1)/)
    xx = (/xo,xo/)
    polyres@gsLineDashPattern = 1
    plot@$unique_string("dum")$ = gsn_add_polyline(wks,plot,xx,yy,polyres)
    polyres@gsLineDashPattern = 0

    ;min
    yy = (/yo(0),yo(0)/)
    xx = (/(xo-(boxWidths/8.)),(xo+(boxWidths/8.))/)
    plot@$unique_string("dum")$ = gsn_add_polyline(wks,plot,xx,yy,polyres)
end
begin
    dq = str_get_dq()
    date_cmd   = "date +" + dq + "%a %b %d %H:%M:%S %Z %Y" + dq
    wcStrt = systemfunc(date_cmd)
;---Processing----------------

;---read observation 
    data_path = "../data/"
    obs_fi = addfile(data_path + "CLDAS/CLDAS_Doksuri.nc" ,"r")
    rain_obs = obs_fi->rain_3day
    lat_obs  = obs_fi->LAT
    lon_obs  = obs_fi->LON
    ;select region
    minlat = 35.
    maxlat = 43.
    minlon = 112.5
    maxlon = 123.5
    ;obs region
    rain_obs_region = rain_obs({minlat:maxlat},{minlon:maxlon})
    lat_obs_region = lat_obs({minlat:maxlat})
    lon_obs_region = lon_obs({minlon:maxlon})
    ;weight of area
    re   = get_sphere_radius()
    ;rad1  = 4.0 * atan(1.0) / 180.0
    rad  = get_d2r("double")
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

    ;Read mesh file
    ;mesh_path = "/storage/aemolcore02/jungu/mesh/rotated_4-60km_28N117E_785410/init_static.nc"
    mesh_path = "/lustre/jungu/MPAS/cases/Microp/input/init_final.nc"
    r2d = get_r2d("double")
    mesh_fi = addfile(mesh_path,"r")
    latCell = mesh_fi->latCell*r2d
    lonCell = mesh_fi->lonCell*r2d
    areaCell = mesh_fi->areaCell

    ;sim region
    index_region = ind(latCell.ge.minlat.and.latCell.le.maxlat.and.lonCell.ge.minlon.and.lonCell.le.maxlon)
    latCell_region = latCell(index_region)
    lonCell_region = lonCell(index_region)
    area_region    = areaCell(index_region)

;---area_rain
    area_rain = new((/4,3/),double)
    ;obs
    rain_obs_50mm = where(rain_obs_region.ge.50,1.,0.)
    area_rain(0,0) = wgt_areasum2(rain_obs_50mm, wgt, 0)
    rain_obs_100mm = where(rain_obs_region.ge.100,1.,0.)
    area_rain(1,0) = wgt_areasum2(rain_obs_100mm, wgt, 0)
    rain_obs_200mm = where(rain_obs_region.ge.200,1.,0.)
    area_rain(2,0) = wgt_areasum2(rain_obs_200mm, wgt, 0)
    rain_obs_400mm = where(rain_obs_region.ge.400,1.,0.)
    area_rain(3,0) = wgt_areasum2(rain_obs_400mm, wgt, 0)
;---read simulations 
    case_list = (/"CTL","RM_T_MP"/)
    ;mean_path_list = data_path + "simulation/0728_12/" + case_list + "/rain_mpas.nc"
    ;process_mpas_rain_area(mean_path_list(0), "rain_3day", index_region, area_region, area_rain(:,1))
    ;process_mpas_rain_area(mean_path_list(1), "rain_3day", index_region, area_region, area_rain(:,2))
    area_rain(:,0) = area_rain(:,0)/1e9
;---read members
    rain_ctl_area_member = new((/4,7/),double)
    rain_rm_t_mp_area_member = new((/4,7/),double)
    member_list = (/"0728_09","0728_10","0728_11","0728_12","0728_13","0728_14","0728_15"/)
    data_path_ctl = "/work/jungu/iAMAS-237-Rainstorm-paper/data/simulation/0728_12/" + case_list(0) + "/member/" \
        + member_list + "/3day/rain_mpas.nc"
    data_path_rm_t_mp = "/work/jungu/iAMAS-237-Rainstorm-paper/data/simulation/0728_12/" + case_list(1) + "/member/" \
        + member_list + "/3day/rain_mpas.nc"
    do imember = 0, 6
        process_mpas_rain_area(data_path_ctl(imember), "rain_3day", index_region, area_region, rain_ctl_area_member(:,imember))
        process_mpas_rain_area(data_path_rm_t_mp(imember), "rain_3day", index_region, area_region, rain_rm_t_mp_area_member(:,imember))
    end do
    rain_ctl_area_member = rain_ctl_area_member/1e9
    rain_rm_t_mp_area_member = rain_rm_t_mp_area_member/1e9
    area_rain(:,1) = dim_avg_n_Wrap(rain_ctl_area_member,1)
    area_rain(:,2) = dim_avg_n_Wrap(rain_rm_t_mp_area_member,1)
    dims = 7 
    x25  = round(.25*dims,3)-1     ; -1 to account for NCL indexing starting -->
    x75  = round(.75*dims,3)-1     ; at 0 -->
    do icase = 0, 3
        qsort(rain_ctl_area_member(icase,:))
        qsort(rain_rm_t_mp_area_member(icase,:))
    end do
    iarr = new((/2,3,5/),double)
    do icase = 1, 3
        iarr(0,icase-1,:) = (/min(rain_ctl_area_member(icase,:)),rain_ctl_area_member(icase,x25),dim_median(rain_ctl_area_member(icase,:)),rain_ctl_area_member(icase,x75),max(rain_ctl_area_member(icase,:))/)
        iarr(1,icase-1,:) = (/min(rain_rm_t_mp_area_member(icase,:)),rain_rm_t_mp_area_member(icase,x25),dim_median(rain_rm_t_mp_area_member(icase,:)),rain_rm_t_mp_area_member(icase,x75),max(rain_rm_t_mp_area_member(icase,:))/)
    end do
;-----------------------------
    wallClockElapseTime(wcStrt, "Processing", 0)
    wcStrtGraphics = systemfunc(date_cmd)
;---Graphics------------------
    wks_name = "Figure3c"
    wks_type = "png"
    N_res = 2
    wks_type@wkHeight = 1024*N_res
    wks_type@wkWidth  = 1024*N_res
    ;wks_type@wkForegroundColor = "gray"
    ;wks_type@wkBackgroundColor = "gray"
    wks = gsn_open_wks(wks_type, wks_name)

    ;set uniform resources
    res = True
    res@gsnDraw = False
    res@gsnFrame= False
    res@gsnMaximize  = False
    res@gsnStringFont = 26
    res@gsnStringFontHeightF = 0.03
    res@gsnLeftString = ""
    res@gsnRightString= ""
    res@gsnLeftStringOrthogonalPosF = 0.015

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
    xyres@trXMaxF = 3.5
    xyres@tmXTOn = False
    xyres@tmYROn = False

    xyres@tmXBMode = "Explicit"
    xyres@tmXBValues = ispan(1,3,1)
    ;xyres@tmXBLabels = "~F25~"+ (/"OBS","CTL","RM_THQ","RM_Q","RM_TH","RM_T"/);,"RM_T_NO_MP"/)
    xyres@tmXBLabels = "~F25~"+ (/"OBS","CTL","RM_T_MP"/)
    xyres@tmXBLabelAngleF = 26
    xyres@tmXBMinorOn = False 
    xyres@tmXBLabelFontHeightF = 0.017
    xyres@tmYLLabelFontHeightF = 0.017
    xyres@tmYRLabelFontHeightF = 0.017

    colors = new((/3/),string)
    colors = (/"Black","Violetred","dodgerblue"/);,"darksalmon","darkslateblue"/)
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
    ;xyres1@gsnLeftString = "(c) Rainfall area above 100/200/400 mm (10~S~3~N~ km~S~2~N~)"
    xyres1@gsnLeftString = ""
    xyres1@trYMinF = 80
    xyres1@trYMaxF = 300
    ;xyres1@xyYStyle = "Log"
    xyres1@tmYLMode = "Explicit"
    xyres1@tmYLValues = fspan(100,300,5)
    xyres1@tmYLMinorValues = fspan(100,300,21)
    xyres1@tmYLLabels = "~F25~"+xyres1@tmYLValues
    xyres1@tmXBBorderOn = False
    xyres1@tiYAxisString = "~F25~> 100 mm"
    plot1 = gsn_csm_xy(wks,ispan(1,3,1),area_rain(1,:),xyres1)

    do n = 0,2
       plot1@$unique_string("")$= gsn_add_text(wks,plot1,sprintf("%3.1f",area_rain(1,n)),n+1,area_rain(1,n)+ 12,txres) ; add labels
    end do
    polyres =  True
    ;polyres@tfPolyDrawOrder  = "PostDraw"
    ;polyres@gsLineOpacityF = 1
    polyres@gsLineThicknessF = 4.5*N_res
    polyres@gsLineColor = colors(1)
    gsn_add_boxplot(wks,plot1,2 + 0.2,iarr(0,0,:),0.15,polyres)
    polyres@gsLineColor = colors(2)
    gsn_add_boxplot(wks,plot1,3 + 0.2,iarr(1,0,:),0.15,polyres)

    yp_min = xyres1@trYMinF
    yp_max = xyres1@trYMaxF
    margin = 0.3
    xp_min = 3 - margin
    xp_max = 3 + margin
    ;dum11 = gsn_add_polygon(wks, plot1, (/xp_min,xp_max,xp_max,xp_min,xp_min/), (/yp_min,yp_min,yp_max,yp_max,yp_min/), plres)
    xp_min = 5 - margin
    xp_max = 6 + margin
    ;dum12 = gsn_add_polygon(wks, plot1, (/xp_min,xp_max,xp_max,xp_min,xp_min/), (/yp_min,yp_min,yp_max,yp_max,yp_min/), plres)

    xyres2 = xyres
    xyres2@trYMinF = 45
    xyres2@trYMaxF = 125
    xyres2@tmYLOn = False
    xyres2@tmYUseLeft = False
    xyres2@tmYROn = True
    xyres2@tmYRLabelsOn = True
    xyres2@tmYRMode = "Explicit"
    xyres2@tmYRValues = fspan(50,120,8)
    xyres2@tmYRMinorValues = fspan(50,120,15)
    xyres2@tmYRLabelFont = 25
    xyres2@tmYRLabels = xyres2@tmYRValues
    ;xyres2@tmXBBorderOn = False
    ;xyres2@tmXTBorderOn = False
    xyres2@tiYAxisString = "~F25~> 200 mm"
    xyres2@tiYAxisSide ="Right"
    plot2 = gsn_csm_xy(wks,ispan(1,3,1),area_rain(2,:),xyres2)

    do n = 0,2
       plot2@$unique_string("")$= gsn_add_text(wks,plot2,sprintf("%3.1f",area_rain(2,n)),n+1,area_rain(2,n)+ 3,txres) ; add labels
    end do
    polyres@gsLineColor = colors(1)
    gsn_add_boxplot(wks,plot2,2 + 0.2,iarr(0,1,:),0.15,polyres)
    polyres@gsLineColor = colors(2)
    gsn_add_boxplot(wks,plot2,3 + 0.2,iarr(1,1,:),0.15,polyres)

    yp_min = xyres2@trYMinF
    yp_max = xyres2@trYMaxF
    xp_min = 3 - margin
    xp_max = 3 + margin
    ;dum21 = gsn_add_polygon(wks, plot2, (/xp_min,xp_max,xp_max,xp_min,xp_min/), (/yp_min,yp_min,yp_max,yp_max,yp_min/), plres)
    xp_min = 5 - margin
    xp_max = 6 + margin
    ;dum22 = gsn_add_polygon(wks, plot2, (/xp_min,xp_max,xp_max,xp_min,xp_min/), (/yp_min,yp_min,yp_max,yp_max,yp_min/), plres)

    ;xyres3 = xyres
    ;xyres3@trYMinF = 0.3
    ;xyres3@trYMaxF = 30
    ;xyres3@xyYStyle = "Log"
    ;xyres3@tmYLMode = "Explicit"
    ;xyres3@tmYLValues = (/0.5,1,2,4,8,16/)
    ;xyres3@tmYLLabels = "~F25~"+xyres3@tmYLValues
    xyres3 = xyres
    xyres3@trYMinF = 0
    xyres3@trYMaxF = 25
    xyres3@tmYLMode = "Explicit"
    xyres3@tmYLValues = fspan(0,25,6)
    xyres3@tmYLMinorValues = fspan(0,25,26)
    xyres3@tmYLLabelFont = 25
    xyres3@tmYLLabels = xyres3@tmYLValues

    xyres3@tmXTBorderOn = False
    xyres3@tiYAxisString = "~F25~> 400 mm"
    plot3 = gsn_csm_xy(wks,ispan(1,3,1),area_rain(3,:),xyres3)

    do n = 0,2
       plot3@$unique_string("")$= gsn_add_text(wks,plot3,sprintf("%3.1f",area_rain(3,n)),n+1,area_rain(3,n)+1,txres) ; add labels
    end do
    polyres@gsLineColor = colors(1)
    gsn_add_boxplot(wks,plot3,2 + 0.2,iarr(0,2,:),0.15,polyres)
    polyres@gsLineColor = colors(2)
    gsn_add_boxplot(wks,plot3,3 + 0.2,iarr(1,2,:),0.15,polyres)

    yp_min := xyres3@trYMinF
    yp_max := xyres3@trYMaxF
    xp_min = 3 - margin
    xp_max = 3 + margin
    ;dum31 = gsn_add_polygon(wks, plot3, (/xp_min,xp_max,xp_max,xp_min,xp_min/), (/yp_min,yp_min,yp_max,yp_max,yp_min/), plres)
    xp_min = 5 - margin
    xp_max = 6 + margin
    ;dum32 = gsn_add_polygon(wks, plot3, (/xp_min,xp_max,xp_max,xp_min,xp_min/), (/yp_min,yp_min,yp_max,yp_max,yp_min/), plres)
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
