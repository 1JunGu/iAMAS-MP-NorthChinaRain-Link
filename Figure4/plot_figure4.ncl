begin
    dq = str_get_dq()
    date_cmd   = "date +" + dq + "%a %b %d %H:%M:%S %Z %Y" + dq
    wcStrt = systemfunc(date_cmd)
;---Processing----------------
    data_path = "../data/"
    ;read trend pl file
    trend_pl_fi = addfile(data_path + "Figure4/Trend_pl.nc", "r")
    t_500hPa = trend_pl_fi->t({500},:,:)
    t_500hPa_prob = trend_pl_fi->t_prob({500},:,:)
    t_500hPa =  t_500hPa*10
    t_500hPa@units = "K/decade"

    trend_pl_noMP_fi = addfile(data_path + "Figure4/Trend_pl_noMP.nc", "r")
    t_500hPa_noMP = trend_pl_noMP_fi->t({500},:,:)
    t_500hPa_noMP = t_500hPa_noMP*43;43 years
    t_500hPa_rmt  = t_500hPa*4.3
    copy_VarCoords(t_500hPa_prob, t_500hPa_noMP)              ; copy coordinate variables
    copy_VarCoords(t_500hPa_prob, t_500hPa_rmt)              ; copy coordinate variables
    ;printVarSummary(t_500hPa_noMP)

    ;read trend sfc file
    trend_sfc_fi = addfile(data_path + "Figure4/Trend_sfc.nc", "r")
    t2m = trend_sfc_fi->t2m
    t2m_prob = trend_sfc_fi->t2m_prob
    t2m =  t2m*10
    t2m@units = "K/decade"

    ;read height/wind/temperature
    height_fi_rmt = addfile(data_path + "Figure3/circulation/RM_T/height_500hPa.nc", "r")
    height_rmt = height_fi_rmt->height_500hPa
    temp_fi_rmt = addfile(data_path + "Figure3/circulation/RM_T/temperature_500hPa.nc", "r")
    temp_rmt = temp_fi_rmt->temperature_500hPa
    uzonal_fi_rmt = addfile(data_path + "Figure3/circulation/RM_T/ERA5/uzonal_500hPa.nc", "r")
    uzonal_rmt = uzonal_fi_rmt->uzonal_500hPa
    umerid_fi_rmt = addfile(data_path + "Figure3/circulation/RM_T/ERA5/umeridional_500hPa.nc", "r")
    umerid_rmt = umerid_fi_rmt->umeridional_500hPa

    height_fi_noMP = addfile(data_path + "Figure3/circulation/RM_T_NO_MP/height_500hPa.nc", "r")
    height_noMP = height_fi_noMP->height_500hPa
    temp_fi_noMP = addfile(data_path + "Figure3/circulation/RM_T_NO_MP/temperature_500hPa.nc", "r")
    temp_noMP = temp_fi_noMP->temperature_500hPa
    uzonal_fi_noMP = addfile(data_path + "Figure3/circulation/RM_T_NO_MP/ERA5/uzonal_500hPa.nc", "r")
    uzonal_noMP = uzonal_fi_noMP->uzonal_500hPa
    umerid_fi_noMP = addfile(data_path + "Figure3/circulation/RM_T_NO_MP/ERA5/umeridional_500hPa.nc", "r")
    umerid_noMP = umerid_fi_noMP->umeridional_500hPa

    height_diff = height_noMP - height_rmt
    temp_diff   = temp_noMP - temp_rmt
    uzonal_diff = uzonal_noMP - uzonal_rmt
    umerid_diff = umerid_noMP - umerid_rmt
    copy_VarCoords(t2m, uzonal_diff)
    copy_VarCoords(t2m, umerid_diff)


    ;read data for plot d
    w_rmt_fi = addfile(data_path + "Figure3/circulation/RM_T/ERA5/w.nc","r")
    w_rmt = w_rmt_fi->w(:,{35:43},{105:130});109-123
    nlevels = w_rmt_fi->nLevels

    qv_rmt_fi = addfile(data_path +"Figure3/circulation/RM_T/ERA5/qv.nc","r")
    qv_rmt = qv_rmt_fi->qv(:,{35:43},{105:130})
    ;noMP
    w_noMP_fi = addfile(data_path + "Figure3/circulation/RM_T_NO_MP/ERA5/w.nc","r")
    w_noMP = w_noMP_fi->w(:,{35:43},{105:130});109-123

    qv_noMP_fi = addfile(data_path +"Figure3/circulation/RM_T_NO_MP/ERA5/qv.nc","r")
    qv_noMP = qv_noMP_fi->qv(:,{35:43},{105:130})

    qv_noMP_avg = dim_avg_n_Wrap(qv_noMP,1)
    qv_rmt_avg = dim_avg_n_Wrap(qv_rmt,1)
    qv_diff = qv_noMP_avg - qv_rmt_avg
    qv_diff =  qv_diff * 1000.0  ; convert to g/kg
    ;qv_diff_perc = (qv_diff/qv_rmt_avg)*100
    w_diff =dim_avg_n_Wrap( w_noMP - w_rmt,1)
    w_diff!0 ="level"
    w_diff&level = nlevels
    w_diff&level@units = "Pa"
    copy_VarCoords(w_diff, qv_diff)              ; copy coordinate variables

    v_diff = w_diff
    v_diff = 0
    ;read rainfall
    rain_obs_fi = addfile(data_path + "Figure1/CLDAS_Doksuri.nc","r")
    rain_obs = rain_obs_fi->rain_3day

    rainc_rmt_fi = addfile(data_path + "Figure2/rainfall/RM_T/rainc_hr.nc","r")
    rainnc_rmt_fi = addfile(data_path + "Figure2/rainfall/RM_T/rainnc_hr.nc","r")
    rain_rmt = (rainc_rmt_fi->rainc_hr  + rainnc_rmt_fi->rainnc_hr)*72

    rainc_noMP_fi = addfile(data_path + "Figure2/rainfall/RM_T_NO_MP/rainc_hr.nc","r")
    rainnc_noMP_fi = addfile(data_path + "Figure2/rainfall/RM_T_NO_MP/rainnc_hr.nc","r")
    rain_noMP = (rainc_noMP_fi->rainc_hr  + rainnc_noMP_fi->rainnc_hr)*72

    ;read static file
    static_fi = addfile("../data/Figure3/cell_fill.nc", "r")
    latCell = static_fi->latCell
    lonCell = static_fi->lonCell

    ;select region
    minlat = 35.
    maxlat = 43.
    minlon = 105.
    maxlon = 130

    index_region = ind(latCell.ge.minlat.and.latCell.le.maxlat.and.lonCell.ge.minlon.and.lonCell.le.maxlon)
    latCell_region = latCell(index_region)
    lonCell_region = lonCell(index_region)
    rain_rmt_region = rain_rmt(index_region)
    rain_noMP_region = rain_noMP(index_region)

    rain_obs_region = rain_obs({minlat:maxlat},{minlon:maxlon})

    lon_interval = fspan(105,130,51);0.5
    rain_region_lon = new((/3,51/),double)
    do i = 0, 50
        index_lon := ind(lonCell_region.ge.lon_interval(i)-0.25.and.lonCell_region.le.lon_interval(i)+0.25)
        rain_region_lon(1,i) = dim_avg_n_Wrap(rain_rmt_region(index_lon), 0)
        rain_region_lon(2,i) = dim_avg_n_Wrap(rain_noMP_region(index_lon), 0)

        rain_obs_subset := rain_obs_region(:,{lon_interval(i)-0.25:lon_interval(i)+0.25})
        rain_region_lon(0,i) = avg(rain_obs_subset)
    end do
;-----------------------------
    wallClockElapseTime(wcStrt, "Processing", 0)
    wcStrtGraphics = systemfunc(date_cmd)
;---Graphics------------------
    wks_name = "Figure4"
    wks_type = "png"
    N_res = 3
    wks_type@wkHeight = 1024*N_res
    wks_type@wkWidth  = 1024*N_res
    wks = gsn_open_wks(wks_type, wks_name)

    ;set uniform resources
    res = True
    res@gsnDraw = False
    res@gsnFrame= False
    res@gsnAddCyclic = False
    res@gsnMaximize  = False
    res@gsnStringFont = 25
    res@gsnStringFontHeightF = 0.018
    res@gsnLeftString = ""
    res@gsnRightString= ""
    res@gsnLeftStringOrthogonalPosF = 0.005
    res@gsnRightStringOrthogonalPosF = 0.02

    ;tickmark
    res@tmXTOn = False
    res@tmYROn = False
    res@tmBorderThicknessF = 4.5*N_res
    res@tmYLMajorThicknessF = 4.5*N_res
    res@tmYLMinorThicknessF = 4.5*N_res
    res@tmYLMajorLengthF    = 0.01
    res@tmYLMinorLengthF    = 0.006
    res@tmXBMajorThicknessF = 4.5*N_res
    res@tmXBMinorThicknessF = 4.5*N_res
    res@tmXBMajorLengthF    = 0.01
    res@tmXBMinorLengthF    = 0.006
    ;res@tmXBMinorOn = False
    ;res@tmYLMinorOn = False
    res@tmXBLabelDeltaF = -0.5
    res@tmYLLabelDeltaF = -0.5
    res@tmXBLabelFontHeightF = 0.016
    res@tmYLLabelFontHeightF = 0.016
    res@tmXBLabelFont = 25
    res@tmYLLabelFont = 25

    minlat = 15
    maxlat = 55
    minlon = 80
    maxlon = 140

    mpres = res
    mpres@mpProjection = "CylindricalEquidistant" ;default projection to draw rectangular box
    mpres@mpLimitMode   	= "LatLon"
    mpres@mpMinLatF = minlat
    mpres@mpMaxLatF = maxlat
    mpres@mpMinLonF = minlon
    mpres@mpMaxLonF = maxlon

    mpres@mpDataSetName     = "/storage/aemolcore02/jungu/Data/Earth..4/Earth..4"
    mpres@mpDataBaseVersion = "LowRes"
    ;outline
    mpres@mpLandFillColor            = "white"
    mpres@mpInlandWaterFillColor     = "white"
    mpres@mpOceanFillColor           = "white"
    ;mpres@mpFillBoundarySets         = "NoBoundaries"
    mpres@mpOutlineOn           = True
    mpres@mpOutlineBoundarySets = "National"
    ;mpres@mpOutlineSpecifiers        = (/"China","China:Provinces"/)
    mpres@mpNationalLineColor        = "black"
    mpres@mpProvincialLineColor      = "black"
    mpres@mpGeophysicalLineColor     = "black"
    mpres@mpGeophysicalLineThicknessF= 3*N_res
    mpres@mpNationalLineThicknessF   = 3*N_res
    mpres@mpProvincialLineThicknessF = 2*N_res

    mpres@tmXBMode = "Explicit"
    mpres@tmXBValues = ispan(80,140,10)
    mpres@tmXBMinorValues = ispan(80,140,5)
    mpres@tmXBLabels = abs(mpres@tmXBValues) + "~S~o~N~E"
    mpres@tmYLMode = "Explicit"
    mpres@tmYLValues = ispan(20,50,10)
    mpres@tmYLMinorValues = ispan(15,55,5)
    mpres@tmYLLabels = abs(mpres@tmYLValues) + "~S~o~N~N" 

    cnres = mpres
    cnres@cnFillDrawOrder = "Draw"
    cnres@cnFillMode = "RasterFill"
    cnres@cnRasterSmoothingOn = True
    cnres@cnFillOn        = True
    cnres@cnInfoLabelOn   = False
    cnres@cnLinesOn       = False
    cnres@cnLineLabelsOn  = False
    cnres@cnLevelSelectionMode = "ExplicitLevels"
    cmap = read_colormap_file("MPL_RdBu")
    colors = new((/42,4/), "float")
    colors = cmap(63-41:64+40:-2,:);
    cnlevels = fspan(-1,1,41)
    cnres@cnLevels        := cnlevels
    cnres@cnFillColors    := colors
    cnres@lbLabelBarOn    = False

    ;vcres
    vcres                       = res
    vcres@gsnLeftString         = ""
    vcres@vcGlyphStyle          = "LineArrow"
    ;vcres@vcGlyphStyle          = "CurlyVector"
    vcres@vcRefLengthF          = 0.03
    vcres@vcLineArrowColor      = "Black"
    vcres@vcMinDistanceF        = 0.023          ; set to small value to thin the vectors.
    vcres@vcLineArrowThicknessF = 3.            ; make the vectors thicker.
    vcres@vcVectorDrawOrder     = "Draw"

    vcres@vcRefAnnoOn               = True
    vcres@vcRefMagnitudeF           = 5.0
    vcres@vcRefAnnoString1          = "~F25~5 m/s"
    vcres@vcRefLengthF              = 0.03   ; define length of vec ref
    vcres@vcRefAnnoFontHeightF      = 0.015
    vcres@vcRefAnnoFontThicknessF   = 1.
    vcres@vcRefAnnoSide             = "Top"
    vcres@vcRefAnnoString2On        = False
    vcres@vcRefAnnoPerimOn          = False
    vcres@vcRefAnnoOrthogonalPosF   = -0.22
    vcres@vcRefAnnoParallelPosF     = 0.997
    vcres@vcRefAnnoBackgroundColor  = "white"

    ;sdres
    sdres = res
    sdres@cnFillOn  = True
    sdres@cnLinesOn = False
    sdres@cnLineLabelsOn = False
    sdres@cnInfoLabelOn = False
    sdres@lbLabelBarOn = False
    sdres@cnLevelSelectionMode ="ExplicitLevels"
    sdres@cnLevels = (/0.05/)             ; 95% confidence level          
    sdres@cnMonoFillPattern = False
    sdres@cnFillPatterns = (/17,-1/);set -1 to no visual
    sdres@cnFillColors = (/1,-1/)
    sdres@cnFillDotSizeF = 0.002
    sdres@cnFillOpacityF = 1 
    ;hgtres
    hgtres = res
    hgtres@cnFillDrawOrder = "PostDraw"
    hgtres@cnFillOn  = False
    hgtres@cnLinesOn = True
    hgtres@cnLineLabelsOn = True
    hgtres@cnLevelSelectionMode = "ExplicitLevels"
    hgtres@cnLevels = (/1,2,3/)
    hgtres@cnLineLabelStrings ="~F25~" +  hgtres@cnLevels + " K"
    hgtres@cnLineLabelFont = 25
    hgtres@cnLineLabelFontHeightF = 0.014
    hgtres@cnExplicitLineLabelsOn  = True
    hgtres@cnLineLabelInterval = 1
    hgtres@cnLineLabelFontColor = "whitesmoke"
    hgtres@cnLineLabelBackgroundColor = -1
    hgtres@cnMonoLineThickness   = True;Important
    ;hgtres@cnLineThicknesses = (/2.5,3,2.5,2.5,2.5/)*N_res
    hgtres@cnLineThicknessF = 3.*N_res
    hgtres@cnMonoLineColor  = True;Important
    hgtres@cnLineColor = "whitesmoke";"whitesmoke"
    hgtres@cnMonoLineDashPattern = True
    hgtres@cnLineDashPatterns = 0
    hgtres@cnInfoLabelOn = False
    hgtres@cnLineLabelPlacementMode = "Constant"

    hgtres@sfXArray = lonCell
    hgtres@sfYArray = latCell

    ;phres
    phres = res
    ;set X axis
    phres@tmXBMode = "Explicit"
    phres@tmXBValues = ispan(110,120,5)
    phres@tmXBMinorValues = ispan(109,123,1)
    phres@tmXBLabels = abs(phres@tmXBValues) + "~S~o~N~E"
    phres@tmXBMajorOutwardLengthF = 0.01
    phres@tmXBMinorOutwardLengthF    = 0.006
    ;phres@trXMinF = 109
    ;phres@trXMaxF = 123
    ;set Y axis
    phres@tiYAxisFontHeightF = 0.018
    phres@tiYAxisPosition = "Center"
    phres@tiYAxisOffsetXF = 0.0
    phres@tiYAxisString = "~F25~" + "Pressure (hPa)"

    phres@tmYLOn = True
    phres@tmYLLabelsOn = True
    phres@tmYROn = False
    phres@tmYLMode = "Explicit"
    phres@tmYLValues = ispan(200, 950, 100)
    YLLabels = "~F25~" + phres@tmYLValues
    phres@tmYLLabels = YLLabels
    phres@trYLog  = False
    phres@trYReverse = True ;reverse the Y axis
    phres@trYMinF = 210

    ;!important
    phres@gsnPresHgtHeightLabelOn = False ;Remove the "height" label

    phres@cnFillOn = True
    phres@cnLinesOn = False
    phres@cnLineLabelsOn = False
    phres@cnLevelSelectionMode = "ExplicitLevels"

    ;printMinMax(w_diff,1)
    ;w_diff@_FillValue = -999.
    ;w_diff = where(w_diff .lt e0.02, w_diff@_FillValue, w_diff)
    ;qv_levels = fspan(-0.5,0.5,41)*100 ;percent
    qv_cnlevels = fspan(-2,2,41) ;percent
    cmap = read_colormap_file("MPL_BrBG")
    qv_colors = new((/42,4/), "float")
    qv_colors = cmap(63-41:64+40:2,:);

    phres@cnLevels = qv_cnlevels
    phres@cnFillColors = qv_colors
    phres@lbLabelBarOn = False
    phres@cnInfoLabelOn = False

    phres@vcRefMagnitudeF       = 0.04                 ; define vector ref mag
    phres@vcMinMagnitudeF       = 0.01
    phres@vcRefLengthF          = 0.03                ; define length of vec ref
    phres@vcMinDistanceF        = 0.0199               ; thin out vectors
    phres@vcGlyphStyle          = "FillArrow";"CurlyVector"        ; turn on curly vecto
    phres@vcFillArrowEdgeThicknessF = 0.01
    phres@vcFillArrowEdgeColor = -1
    ;phres@vcFillOverEdge = False

    phres@vcRefAnnoOn               = True
    phres@vcRefAnnoString1          = "~F25~0.04 m/s"
    phres@vcRefAnnoString2On        = False
    phres@vcRefAnnoFontHeightF      = 0.015
    phres@vcRefAnnoFontThicknessF   = 1.
    phres@vcRefAnnoSide             = "Top"
    phres@vcRefAnnoPerimOn          = False
    phres@vcRefAnnoOrthogonalPosF   = -0.15
    phres@vcRefAnnoParallelPosF     = 0.997
    phres@vcRefAnnoBackgroundColor  = "white"

    phres@vpWidthF = 0.62
    phres@vpHeightF = 0.46667

    xyres = res
    xyres@vpWidthF = 0.62
    xyres@vpHeightF = 0.46667

    xyres@tmXBMode = "Explicit"
    xyres@tmXBValues = ispan(110,120,5)
    xyres@tmXBMinorValues = ispan(109,123,1)
    xyres@tmXBLabels = abs(phres@tmXBValues) + "~S~o~N~E"
    xyres@tmXBMajorOutwardLengthF = 0.01
    xyres@tmXBMinorOutwardLengthF    = 0.006

    xyres@tmYUseLeft = False
    xyres@tmYLOn = False
    xyres@tmYROn = True
    xyres@tmYRMode = "Explicit"
    xyres@tmYRValues = fspan(0,300,7)
    xyres@tmYRLabels = "~F25~"+xyres@tmYRValues
    xyres@tmYRMinorValues = ispan(0,300,10)
    xyres@tmYRLabelsOn = True
    xyres@tmYRLabelFont = 25
    xyres@tmYRMajorLengthF = 0.01
    xyres@tmYRMinorLengthF = 0.006
    xyres@tmYRMajorOutwardLengthF = 0.01
    xyres@tmYRMinorOutwardLengthF = 0.006
    xyres@tmYRMajorThicknessF= 4.5 * N_res
    xyres@tmYRMinorThicknessF= 4.5 * N_res
    xyres@tmYRLabelFontHeightF = 0.014

    xyres@trYMinF = -2
    xyres@trYMaxF = 252
    ;xyres@tmYRLabelFontHeightF = 0.017

    xyres@tiYAxisSide ="Right"
    xyres@tiYAxisString = "~F25~" + "Rainfall (mm)"
    xyres@tiYAxisFontHeightF = 0.018

    xyres@xyDashPatterns  = (/14,0,0/) ; Make curves all solid except offical forecast
    xyres@xyMarkLineMode = "Lines"
    xyres@xyLineThicknesses = (/5,5,5/)*N_res

    xyres@trXMinF = 109
    xyres@trXMaxF = 123


    contour = new(6,graphic)
    shade   = new(2,graphic);figure a and b
    vector  = new(2,graphic);figure b and c

    cnres@gsnLeftString = "(a) 2m temperature trend"
    contour(0) = gsn_csm_contour_map(wks, t2m, cnres)
    shade(0) = gsn_csm_contour(wks, t2m_prob, sdres)
    overlay(contour(0), shade(0))
    cnres@gsnLeftString = "(b) 500hPa temperature trend"
    contour(1) = gsn_csm_contour_map(wks, t_500hPa, cnres)
    shade(1) = gsn_csm_contour(wks, t_500hPa_prob, sdres)
    overlay(contour(1), shade(1))

    cnres@gsnLeftString = "(c) CTL - RM_T"
    cmap = read_colormap_file("MPL_RdBu")
    cmap = cmap(::-1,:)
    t_diff_colors = new((/41,4/), "float")
    t_diff_colors(0:19,:) = cmap(24:62:2,:);
    t_diff_colors(20,:)   = (/1.,1.,1.,1./)
    t_diff_colors(21:40,:) = cmap(67:124:3,:);
    t_diff_cnlevels = new((/40/), "float")
    t_diff_cnlevels(0:19) = fspan(-3,-0.15,20)
    t_diff_cnlevels(20:39) = fspan(0.15,3,20)
    ;print(t_diff_cnlevels)
    ;printMinMax(t_500hPa_rmt,1)
    cnres@cnLevels        := t_diff_cnlevels
    cnres@cnFillColors    := t_diff_colors
    contour(2) = gsn_csm_contour_map(wks, t_500hPa_rmt, cnres)
    cnres@gsnLeftString = "(d) CTL - RM_T_NO_MP"
    contour(3) = gsn_csm_contour_map(wks, t_500hPa_noMP, cnres)


    cnres@gsnLeftString = "(e) RM_T_NO_MP - RM_T"
    cnres@sfXArray = lonCell
    cnres@sfYArray = latCell
    ;cmap = read_colormap_file("MPL_RdBu")
    hgt_cmap = read_colormap_file("BlueRed")
    hgt_colors = new((/42,4/), "float")
    ;hgt_colors = cmap(127-41:128+40:-2,:);
    hgt_colors = hgt_cmap(23:228:5,:);
    hgt_cnlevels = fspan(-40,40,41)
    cnres@cnLevels        := hgt_cnlevels
    cnres@cnFillColors    := hgt_colors
    contour(4) = gsn_csm_contour_map(wks, height_diff, cnres)
    ;hgtres@cnLineColor = "turquoise"
    contour_temp = gsn_csm_contour(wks,temp_diff,hgtres)
    ;hgtres@cnLineColor = "darkslateblue"
    ;contour_rmt = gsn_csm_contour(wks,height_noMP,hgtres)
    vector(0) = gsn_csm_vector(wks, uzonal_diff, umerid_diff, vcres)
    overlay(contour(4), vector(0))
    overlay(contour(4), contour_temp)

    phres@gsnLeftString = "(f) RM_T_NO_MP - RM_T"
    phres@cnMissingValFillColor = "gray35"
    contour(5)= gsn_csm_pres_hgt_vector(wks, qv_diff, v_diff, w_diff, phres)
    xy_colors = (/"Black","turquoise","darkslateblue"/)
    xyres@xyLineColors   = xy_colors
    rainfall_xy = gsn_csm_xy(wks,lon_interval,rain_region_lon,xyres)

    lnres = True
    lnres@gsLineColor = "Black"
    lnres@gsLineThicknessF = 5*N_res
    lnres@gsLineDashPattern = 14
    txres = True
    txres@txFontHeightF = 0.014
    txres@txFont = 25
    txres@txJust = "CenterLeft"
    ln_x = 109.2
    ln_x2= 110.2
    item_y1 = 240
    item_y2 = 220
    item_y3 = 200

    dummy1 = gsn_add_polyline(wks, rainfall_xy, (/ln_x,ln_x2/), (/item_y1,item_y1/), lnres)
    dummy2 = gsn_add_text(wks, rainfall_xy,"OBS", ln_x2+0.2, item_y1, txres)

    lnres@gsLineColor = "turquoise"
    lnres@gsLineDashPattern = 0
    dummy3 = gsn_add_polyline(wks, rainfall_xy, (/ln_x,ln_x2/), (/item_y2,item_y2/), lnres)
    dummy4 = gsn_add_text(wks, rainfall_xy,"RM_T", ln_x2+0.2, item_y2, txres)

    lnres@gsLineColor = "darkslateblue"
    dummy5 = gsn_add_polyline(wks, rainfall_xy, (/ln_x,ln_x2/), (/item_y3,item_y3/), lnres)
    dummy6 = gsn_add_text(wks, rainfall_xy,"RM_T_NO_MP", ln_x2+0.2, item_y3, txres)

    anno_id1 = gsn_add_annotation(contour(5), rainfall_xy, False)

    ;cnres@gsnLeftString = "(d) CTL - RM_T_NO_MP"
    ;cnres@sfXArray = lonCell
    ;cnres@sfYArray = latCell
    ;contour(3) = gsn_csm_contour_map(wks, temp_diff(1,:), cnres)
    ;hgtres@cnLineColor = "Black"
    ;contour_ctl1 = gsn_csm_contour(wks,height_ctl,hgtres)
    ;contour_noMP = gsn_csm_contour(wks,height_noMP,hgtres)
    ;vector(1) = gsn_csm_vector(wks, uzonal_diff(1,:,:), umerid_diff(1,:,:), vcres)
    ;overlay(contour(3), contour_ctl1)
    ;overlay(contour(3), contour_noMP)
    ;overlay(contour(3), vector(1))

    box_lat = (/35,35,50,50,35/)
    box_lon = (/85,115,115,85,85/)
    plres   = True
    plres@gsLineDashPattern = 0
    plres@gsLineColor = "dimgray"
    plres@gsLineThicknessF = 5*N_res
    box0 = gsn_add_polyline(wks, shade(0), box_lon, box_lat, plres)
    box1 = gsn_add_polyline(wks, shade(1), box_lon, box_lat, plres)
    box2 = gsn_add_polyline(wks, contour(3), box_lon, box_lat, plres)

    ;Create common label
    lbres = True
    lbres@lbPerimOn = False
    lbres@lbBoxLinesOn = True
    lbres@lbBoxSeparatorLinesOn = False
    lbres@lbBoxLineThicknessF = 1.2*N_res
    lbres@lbOrientation = "horizontal"
    lbres@lbMonoFillPattern = True
    lbres@lbLabelFont = 25
    lbres@lbLabelFontHeightF = 0.01
    lbres@lbLabelAlignment   = "InteriorEdges"
    lbres@lbTitlePosition = "Bottom"
    lbres@lbTitleFontHeightF = 0.011
    lbres@lbTitleOffsetF = 0.2
    lbres@lbTitleExtentF = 0.25

    ;create trend labelbar
    lbres1 = lbres
    lbres1@vpXF = 0.2
    lbres1@vpYF = 0.7
    lbres1@vpWidthF = 0.6
    lbres1@vpHeightF= 0.04

    lbres1@lbFillColors  := colors
    lbres1@lbTitleString = "~F25~Temperature trend (K/decade)";optional
    lbres1@lbLabelStride = 4
    lbid_trend = gsn_create_labelbar(wks,dimsizes(colors),cnlevels,lbres1)
    draw(lbid_trend)
    ;create temperature difference labelbar
    lbres2 = lbres
    lbres2@vpXF = 0.2
    lbres2@vpYF = 0.385
    lbres2@vpWidthF = 0.6
    lbres2@vpHeightF= 0.04

    lbres2@lbFillColors  := t_diff_colors
    lbres2@lbTitleString = "~F25~Temperature differences at 500 hPa (K)";optional
    lbres2@lbLabelStride = 1
    nboxes := dimsizes(t_diff_colors)
    lbid_tdiff = gsn_create_labelbar(wks,nboxes,""+t_diff_cnlevels,lbres2)
    draw(lbid_tdiff)
    ;create height diff labelbar
    lbres3 = lbres
    lbres3@vpXF = 0.15
    lbres3@vpYF = 0.074
    lbres3@vpWidthF = 0.3
    lbres3@vpHeightF= 0.04

    lbres3@lbFillColors  := hgt_colors
    lbres3@lbTitleString = "~F25~GHT differences at 500 hPa (K)";optional
    lbres3@lbLabelStride = 1
    nboxes := dimsizes(hgt_colors)
    lbid_hdiff = gsn_create_labelbar(wks,nboxes,"" + hgt_cnlevels,lbres3)
    draw(lbid_hdiff)

    ;create qv diff labelbar
    lbres4 = lbres
    lbres4@vpXF = 0.55
    lbres4@vpYF = 0.074
    lbres4@vpWidthF = 0.28
    lbres4@vpHeightF= 0.04

    lbres4@lbFillColors  := qv_colors
    lbres4@lbTitleString = "~F25~Water vapor differences (g/kg)";optional
    lbres4@lbLabelStride = 1
    nboxes := dimsizes(qv_colors)
    lbid_qv = gsn_create_labelbar(wks,nboxes,""+qv_cnlevels,lbres4)
    draw(lbid_qv)

    resP = True
    resP@gsnPanelLabelBar = False
    resP@gsnMaximize = True
    resP@gsnPanelRowSpec = True
    resP@gsnPanelCenter = True
    ;resP@gsnPanelDebug = True
    resP@gsnPanelYWhiteSpacePercent = 10
    resP@gsnPanelBottom = 0.06
    ;resP@gsnPanelTop = 0.99
    gsn_panel(wks,contour,(/2,2,2/),resP)
    ;drawNDCGrid(wks)

;-----------------------------
    wallClockElapseTime(wcStrtGraphics, "Graphics", 0)
    wallClockElapseTime(wcStrt, "Processing and Graphics", 0)
end
