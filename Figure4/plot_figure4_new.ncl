begin
    dq = str_get_dq()
    date_cmd   = "date +" + dq + "%a %b %d %H:%M:%S %Z %Y" + dq
    wcStrt = systemfunc(date_cmd)
    Re = get_sphere_radius()
;---Processing----------------
    data_path = "../data/simulation/0728_12/"
    ;read height/wind/temperature
    height_fi_ctl = addfile(data_path + "/CTL/height_isobaric.nc", "r")
    height_ctl = height_fi_ctl->height(:,19)
    height_ctl_fix = Re*height_ctl/(Re + height_ctl)

    temp_fi_ctl = addfile(data_path + "/CTL/ensemble/daily_avg/3day/temperature_500hPa.nc", "r")
    temp_ctl = temp_fi_ctl->temperature_500hPa
    uzonal_fi_ctl = addfile(data_path + "CTL/ERA5/uReconstructZonal.nc", "r")
    uzonal_ctl = uzonal_fi_ctl->uReconstructZonal({50000},:,:)
    umerid_fi_ctl = addfile(data_path + "/CTL/ERA5/uReconstructMeridional.nc", "r")
    umerid_ctl = umerid_fi_ctl->uReconstructMeridional({50000},:,:)
    qv_fi_ctl = addfile(data_path + "/CTL/ERA5/qv.nc", "r")
    qv_ctl_500 = qv_fi_ctl->qv({50000},:,:)

    height_fi_rm_t_mp = addfile(data_path + "/RM_T_MP/height_isobaric.nc", "r")
    height_rm_t_mp = height_fi_rm_t_mp->height(:,19)
    height_rm_t_mp_fix = Re*height_rm_t_mp/(Re + height_rm_t_mp)

    temp_fi_rm_t_mp = addfile(data_path + "/RM_T_MP/ensemble/daily_avg/3day/temperature_500hPa.nc", "r")
    temp_rm_t_mp = temp_fi_rm_t_mp->temperature_500hPa
    uzonal_fi_rm_t_mp = addfile(data_path + "RM_T_MP/ERA5/uReconstructZonal.nc", "r")
    uzonal_rm_t_mp = uzonal_fi_rm_t_mp->uReconstructZonal({50000},:,:)
    umerid_fi_rm_t_mp = addfile(data_path + "/RM_T_MP/ERA5/uReconstructMeridional.nc", "r")
    umerid_rm_t_mp = umerid_fi_rm_t_mp->uReconstructMeridional({50000},:,:)
    qv_fi_rm_t_mp = addfile(data_path + "/RM_T_MP/ERA5/qv.nc", "r")
    qv_rm_t_mp_500 = qv_fi_rm_t_mp->qv({50000},:,:)

    height_diff = height_ctl_fix - height_rm_t_mp_fix
    temp_diff   = temp_ctl - temp_rm_t_mp
    uzonal_diff = uzonal_ctl - uzonal_rm_t_mp
    umerid_diff = umerid_ctl - umerid_rm_t_mp
    copy_VarCoords(uzonal_ctl, uzonal_diff)
    copy_VarCoords(uzonal_ctl, umerid_diff)

    qu_diff_exps = new((/721,1440/),double)
    qv_diff_exps = new((/721,1440/),double)
    qu_diff_exps!0 = "lat"
    qu_diff_exps!1 = "lon"
    qu_diff_exps&lat = uzonal_ctl&lat
    qu_diff_exps&lon = umerid_ctl&lon
    copy_VarMeta(qu_diff_exps, qv_diff_exps)

    qu_diff_exps = (qv_ctl_500*uzonal_ctl - qv_rm_t_mp_500*uzonal_rm_t_mp)*1e3
    qv_diff_exps = (qv_ctl_500*umerid_ctl - qv_rm_t_mp_500*umerid_rm_t_mp)*1e3



    ;read data for plot d
    w_rmt_fi = addfile(data_path + "/CTL/ERA5/w.nc","r")
    w_rmt = w_rmt_fi->w(:,{35:41},{105:130});109-123
    nlevels = w_rmt_fi->nLevels

    qv_rmt_fi = addfile(data_path +"/CTL/ERA5/qv.nc","r")
    qv_rmt = qv_rmt_fi->qv(:,{35:41},{105:130})
    ;noMP
    w_noMP_fi = addfile(data_path + "/RM_T_MP/ERA5/w.nc","r")
    w_noMP = w_noMP_fi->w(:,{35:41},{105:130});109-123

    qv_noMP_fi = addfile(data_path +"/RM_T_MP/ERA5/qv.nc","r")
    qv_noMP = qv_noMP_fi->qv(:,{35:41},{105:130})

    qv_noMP_avg = dim_avg_n_Wrap(qv_noMP,1)
    qv_rmt_avg = dim_avg_n_Wrap(qv_rmt,1)
    qv_diff =  qv_rmt_avg - qv_noMP_avg
    qv_diff =  qv_diff * 1000.0  ; convert to g/kg
    ;qv_diff_perc = (qv_diff/qv_rmt_avg)*100
    w_diff =dim_avg_n_Wrap( w_rmt - w_noMP,1)
    w_diff!0 ="level"
    w_diff&level = nlevels
    w_diff&level@units = "Pa"
    copy_VarCoords(w_diff, qv_diff)              ; copy coordinate variables

    v_diff = w_diff
    v_diff = 0
    ;read rainfall
    ;rain_obs_fi = addfile(data_path + "Figure1/CLDAS_Doksuri.nc","r")
    ;rain_obs = rain_obs_fi->rain_3day
    rain_ctl_fi = addfile(data_path + "/CTL/rain_mpas.nc","r")
    rain_ctl = rain_ctl_fi->rain_3day


    ;rainc_rmt_fi = addfile(data_path + "Figure2/rainfall/RM_T/rainc_hr.nc","r")
    ;rainnc_rmt_fi = addfile(data_path + "Figure2/rainfall/RM_T/rainnc_hr.nc","r")
    ;rain_rmt = (rainc_rmt_fi->rainc_hr  + rainnc_rmt_fi->rainnc_hr)*72

    rain_noMP_fi = addfile(data_path + "/RM_T_MP/rain_mpas.nc","r")
    rain_noMP = rain_noMP_fi->rain_3day
    rain_diff_exps = rain_ctl - rain_noMP

    ;read static file
    static_fi = addfile(data_path + "../cell_fill.nc","r")
    latCell = static_fi->latCell
    lonCell = static_fi->lonCell

    ;select region
    minlat = 35.
    maxlat = 41.
    minlon = 105.
    maxlon = 130

    index_region = ind(latCell.ge.minlat.and.latCell.le.maxlat.and.lonCell.ge.minlon.and.lonCell.le.maxlon)
    latCell_region = latCell(index_region)
    lonCell_region = lonCell(index_region)
    rain_ctl_region = rain_ctl(index_region)
    ;rain_rmt_region = rain_rmt(index_region)
    rain_noMP_region = rain_noMP(index_region)

    ;rain_obs_region = rain_obs({minlat:maxlat},{minlon:maxlon})

    lon_interval = fspan(105,130,51);0.5
    rain_region_lon = new((/2,51/),double)
    do i = 0, 50
        index_lon := ind(lonCell_region.ge.lon_interval(i)-0.25.and.lonCell_region.le.lon_interval(i)+0.25)
        rain_region_lon(0,i) = dim_avg_n_Wrap(rain_ctl_region(index_lon), 0)
        ;rain_region_lon(1,i) = dim_avg_n_Wrap(rain_rmt_region(index_lon), 0)
        rain_region_lon(1,i) = dim_avg_n_Wrap(rain_noMP_region(index_lon), 0)

        ;rain_obs_subset := rain_obs_region(:,{lon_interval(i)-0.25:lon_interval(i)+0.25})
        ;rain_region_lon(0,i) = avg(rain_obs_subset)
    end do
;-----------------------------
    wallClockElapseTime(wcStrt, "Processing", 0)
    wcStrtGraphics = systemfunc(date_cmd)
;---Graphics------------------
    wks_name = "Figure4"
    wks_type = "png"
    N_res = 4
    wks_type@wkHeight = 1024*N_res
    wks_type@wkWidth  = 1024*N_res
    wks = gsn_open_wks(wks_type, wks_name)

    ;set uniform resources
    res = True
    res@gsnDraw = False
    res@gsnFrame= False
    res@gsnAddCyclic = False
    res@gsnMaximize  = False
    res@gsnStringFont = 26
    res@gsnLeftStringFontHeightF = 0.03
    res@gsnCenterStringFontHeightF = 0.022
    res@gsnLeftString = ""
    res@gsnRightString= ""
    res@gsnLeftStringOrthogonalPosF = 0.02
    res@gsnCenterStringOrthogonalPosF = 0.02
    res@gsnRightStringOrthogonalPosF = 0.02
    ;res@vpHeightF = 0.8
    ;res@vpWidthF  = 0.8

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
    mpres@mpMinLatF = 30
    mpres@mpMaxLatF = 54
    mpres@mpMinLonF = 95
    mpres@mpMaxLonF = 131

    mpres@mpDataSetName     = "$HOME/.config/NCL/database/Earth..4"
    mpres@mpDataBaseVersion = "MediumRes"
    ;outline
    mpres@mpLandFillColor            = "white"
    mpres@mpInlandWaterFillColor     = "white"
    mpres@mpOceanFillColor           = "white"
    ;mpres@mpFillBoundarySets         = "NoBoundaries"
    mpres@mpOutlineOn           = True
    mpres@mpOutlineBoundarySets = "National"
    mpres@mpOutlineSpecifiers        = (/"China","China:Provinces"/)
    mpres@mpNationalLineColor        = "black"
    mpres@mpProvincialLineColor      = "black"
    mpres@mpGeophysicalLineColor     = "black"
    mpres@mpGeophysicalLineThicknessF= 1*N_res
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

    cnares = res
    cnares@gsnLeftString = ""
    cnares@cnFillDrawOrder = "PostDraw"
    cnares@cnFillOn  = False
    cnares@cnLinesOn = True
    cnares@cnLevelSelectionMode = "ExplicitLevels"
    cnares@cnLevels = (/588/)*10
    cnares@sfXArray = lonCell
    cnares@sfYArray = latCell

    cnares@cnLineThicknessF = 5*N_res
    cnares@cnLineDashPattern = 0
    cnares@cnInfoLabelOn = False
    cnares@cnLineLabelFont = 25
    cnares@cnLineLabelsOn = False

    mpares = res
    mpares@mpProjection = "CylindricalEquidistant" ;default projection to draw rectangular box
    mpares@mpLimitMode   	= "LatLon"
    mpares@mpMinLatF = 30
    mpares@mpMaxLatF = 54
    mpares@mpMinLonF = 95
    mpares@mpMaxLonF = 131

    mpares@mpDataSetName     = "$HOME/.config/NCL/database/Earth..4"
    mpares@mpDataBaseVersion        = "MediumRes"
    mpares@mpOutlineOn              =  True
    mpares@mpOutlineSpecifiers        = (/"China","China:Provinces"/)
    mpares@mpLandFillColor            = "white"
    mpares@mpInlandWaterFillColor     = "white"
    mpares@mpOceanFillColor           = "white"
    ;mpares@mpFillBoundarySets         = "NoBoundaries"
    ;mpares@mpOutlineBoundarySets      = "NoBoundaries"
    mpares@mpOutlineBoundarySets      = "National"
    mpares@mpNationalLineColor        = "black"
    mpares@mpProvincialLineColor      = "black"
    mpares@mpGeophysicalLineColor     = "black"
    mpares@mpGeophysicalLineThicknessF = 1*N_res
    mpares@mpNationalLineThicknessF   = 3*N_res
    mpares@mpProvincialLineThicknessF = 2*N_res

    mpares@tmXBMode = "Explicit"
    mpares@tmXBValues = ispan(80,140,10)
    mpares@tmXBLabels = mpares@tmXBValues + "~S~o~N~E"
    mpares@tmXBMinorValues = ispan(80,140,5)

    mpares@tmYLMode = "Explicit"
    mpares@tmYLValues = ispan(20,50,10)
    mpares@tmYLLabels = mpares@tmYLValues + "~S~o~N~N"
    mpares@tmYLMinorValues = ispan(15,55,5)


    sdares = mpares
    sdares@cnFillDrawOrder = "Draw"
    sdares@cnFillOn = True
    sdares@cnLinesOn = False
    sdares@cnInfoLabelOn   = False
    sdares@cnLineLabelsOn  = False

    sdares@cnFillMode = "RasterFill"
    sdares@trGridType = "TriangularMesh"
    ;sdares@cnRasterSmoothingOn = True
    sdares@sfXArray =lonCell
    sdares@sfYArray =latCell

    sdares@cnLevelSelectionMode = "ExplicitLevels"
    rain_diff_levels = fspan(-200,200,51); rain difference
    rain_diff_cmap =  read_colormap_file("MPL_BrBG")
    rain_diff_colors = new((/52,4/),"float")
    rain_diff_colors = rain_diff_cmap(12:114:2,:)

    sdares@cnLevels        = rain_diff_levels
    sdares@cnFillColors    = rain_diff_colors
    sdares@lbLabelBarOn    = False

    vcares                       = res
    vcares@gsnLeftString  = ""
    vcares@vcGlyphStyle          = "LineArrow"
    ;vcares@vcGlyphStyle          = "CurlyVector"
    vcares@vcLineArrowColor      = "Black"
    vcares@vcMinDistanceF        = 0.023          ; set to small value to thin the vectors.
    vcares@vcLineArrowThicknessF = 2.*N_res            ; make the vectors thicker.
    vcares@vcVectorDrawOrder     = "PostDraw"

    vcares@vcRefAnnoOn               = True
    vcares@vcRefMagnitudeF           = 50.0
    vcares@vcRefAnnoString1          = "~F25~50"
    vcares@vcRefLengthF              = 0.04   ; define length of vec ref
    vcares@vcRefAnnoFontHeightF      = 0.015
    vcares@vcRefAnnoFontThicknessF   = 1.
    vcares@vcRefAnnoSide             = "Top"
    vcares@vcRefAnnoString2On        = True
    vcares@vcRefAnnoString2          = "~F25~g/kg m/s"
    vcares@vcRefAnnoPerimOn          = False
    vcares@vcRefAnnoOrthogonalPosF   = -0.304
    vcares@vcRefAnnoParallelPosF     = 0.995
    vcares@vcRefAnnoBackgroundColor  = "white"


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
    vcres@vcRefAnnoOrthogonalPosF   = -0.245
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
    hgtres@cnLineLabelFontColor = "white"
    ;hgtres@cnLineLabelBackgroundColor = "white"
    hgtres@cnMonoLineThickness   = True;Important
    ;hgtres@cnLineThicknesses = (/2.5,3,2.5,2.5,2.5/)*N_res
    hgtres@cnLineThicknessF = 3.*N_res
    hgtres@cnMonoLineColor  = True;Important
    hgtres@cnLineColor = "white";"whitesmoke"
    hgtres@cnMonoLineDashPattern = True
    hgtres@cnLineDashPatterns = 0
    hgtres@cnInfoLabelOn = False
    hgtres@cnLineLabelPlacementMode = "constant"

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

    phres@vcRefMagnitudeF       = 0.05                 ; define vector ref mag
    phres@vcMinMagnitudeF       = 0.005
    phres@vcRefLengthF          = 0.04                ; define length of vec ref
    phres@vcMinDistanceF        = 0.0199               ; thin out vectors
    phres@vcGlyphStyle          = "FillArrow";"CurlyVector"        ; turn on curly vecto
    phres@vcFillArrowEdgeThicknessF = 0.01
    phres@vcFillArrowEdgeColor = -1
    ;phres@vcFillOverEdge = False

    phres@vcRefAnnoOn               = True
    phres@vcRefAnnoString1          = "~F25~0.05 m/s"
    phres@vcRefAnnoString2On        = False
    phres@vcRefAnnoFontHeightF      = 0.015
    phres@vcRefAnnoFontThicknessF   = 1.
    phres@vcRefAnnoSide             = "Top"
    phres@vcRefAnnoPerimOn          = False
    phres@vcRefAnnoOrthogonalPosF   = -0.17
    phres@vcRefAnnoParallelPosF     = 0.999
    phres@vcRefAnnoBackgroundColor  = "white"

    phres@vpWidthF = 0.72
    phres@vpHeightF = 0.46667

    xyres = res
    xyres@vpWidthF = 0.72
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
    xyres@trYMaxF = 312
    ;xyres@tmYRLabelFontHeightF = 0.017

    xyres@tiYAxisSide ="Right"
    xyres@tiYAxisString = "~F25~" + "Rainfall (mm)"
    xyres@tiYAxisFontHeightF = 0.018

    xyres@xyDashPatterns  = (/0,0,0/) ; Make curves all solid except offical forecast
    xyres@xyMarkLineMode = "Lines"
    xyres@xyLineThicknesses = (/5,5,5/)*N_res

    xyres@trXMinF = 109
    xyres@trXMaxF = 123


    contour = new(3,graphic)
    vector  = new(3,graphic);figure b and c

    cnres@gsnLeftString = "a "
    cnres@gsnCenterString = "Impact of MP warming on circulation"
    cnres@sfXArray = lonCell
    cnres@sfYArray = latCell
    ;cmap = read_colormap_file("MPL_RdBu")
    hgt_cmap = read_colormap_file("BlueRed")
    hgt_colors = new((/32,4/), "float")
    ;hgt_colors = cmap(127-41:128+40:-2,:);
    hgt_colors = hgt_cmap(17:234:7,:);
    hgt_cnlevels = fspan(-30,30,31)
    cnres@cnLevels        := hgt_cnlevels
    cnres@cnFillColors    := hgt_colors
    contour(0) = gsn_csm_contour_map(wks, height_diff, cnres)
    ;hgtres@cnLineColor = "turquoise"
    contour_temp = gsn_csm_contour(wks,temp_diff,hgtres)
    ;hgtres@cnLineColor = "darkslateblue"
    ;contour_rmt = gsn_csm_contour(wks,height_noMP,hgtres)
    vector(0) = gsn_csm_vector(wks, uzonal_diff, umerid_diff, vcres)
    overlay(contour(0), vector(0))
    overlay(contour(0), contour_temp)

    sdares@gsnLeftString     = "b "
    sdares@gsnCenterString = "Barrier effect from MP warming"
    ;sdares@vpWidthF = 0.58947
    ;sdares@vpHeightF = 0.46667
    contour(1) = gsn_csm_contour_map(wks,rain_diff_exps,sdares)
    ;cnares@vpWidthF = 0.58947
    ;cnares@vpHeightF = 0.46667
    cnares@cnLineColor     = "Violetred"
    height_plot = gsn_csm_contour(wks,height_ctl_fix,cnares)
    cnares@cnLineColor     = "dodgerblue"
    height_plot1= gsn_csm_contour(wks,height_rm_t_mp_fix,cnares)
    ;vcares@vpWidthF = 0.58947
    ;vcares@vpHeightF = 0.46667
    vector(1)  = gsn_csm_vector(wks,qu_diff_exps,qv_diff_exps,vcares)
    overlay(contour(1),height_plot)
    overlay(contour(1),height_plot1)
    overlay(contour(1),vector(1))

    phres@gsnLeftString = "c "
    phres@gsnCenterString = "Vertical barrier effect from MP warming"
    phres@cnMissingValFillColor = "gray35"
    contour(2)= gsn_csm_pres_hgt_vector(wks, qv_diff, v_diff, w_diff, phres)
    xy_colors = (/"violetred","dodgerblue"/)
    xyres@xyLineColors   = xy_colors
    rainfall_xy = gsn_csm_xy(wks,lon_interval,rain_region_lon,xyres)

    lnres = True
    lnres@gsLineColor = "violetred"
    lnres@gsLineThicknessF = 5*N_res
    lnres@gsLineDashPattern = 0
    txres = True
    txres@txFontHeightF = 0.014
    txres@txFont = 25
    txres@txJust = "CenterLeft"
    ln_x = 119.2
    ln_x2= 120.2
    item_y1 = 250
    item_y2 = 230
    item_y3 = 210

    dummy1 = gsn_add_polyline(wks, rainfall_xy, (/ln_x,ln_x2/), (/item_y1,item_y1/), lnres)
    dummy2 = gsn_add_text(wks, rainfall_xy,"CTL", ln_x2+0.2, item_y1, txres)

    lnres@gsLineColor = "dodgerblue"
    lnres@gsLineDashPattern = 0
    dummy3 = gsn_add_polyline(wks, rainfall_xy, (/ln_x,ln_x2/), (/item_y2,item_y2/), lnres)
    dummy4 = gsn_add_text(wks, rainfall_xy,"RM_T_MP", ln_x2+0.2, item_y2, txres)

    ;lnres@gsLineColor = "darkslateblue"
    ;dummy5 = gsn_add_polyline(wks, rainfall_xy, (/ln_x,ln_x2/), (/item_y3,item_y3/), lnres)
    ;dummy6 = gsn_add_text(wks, rainfall_xy,"RM_T_MP", ln_x2+0.2, item_y3, txres)

    anno_id1 = gsn_add_annotation(contour(2), rainfall_xy, False)

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

    plres   = True
    plres@gsLineDashPattern = 0
    plres@gsLineThicknessF  = 4*N_res
    plres@gsLineColor = "Black"

    box_lat = (/35,35,41,41,35/)
    box_lon = (/112.5,117.5,117.5,112.5,112.5/)
    ;plres@gsLineThicknessF = 10
    box0 = gsn_add_polyline(wks, contour(0), box_lon, box_lat, plres)
    box1 = gsn_add_polyline(wks, contour(1), box_lon, box_lat, plres)
    box2 = gsn_add_polyline(wks, contour(2), box_lon, box_lat, plres)


    ;Create common label
    lbres = True
    lbres@lbPerimOn = False
    lbres@lbBoxLinesOn = False
    lbres@lbBoxSeparatorLinesOn = False
    lbres@lbBoxLineThicknessF = 1.2*N_res

    lbres@lbMonoFillPattern = True
    lbres@lbLabelFontHeightF = 0.008
    lbres@lbLabelAlignment   = "InteriorEdges"
    lbres@lbOrientation = "horizontal"
    lbres@lbTitlePosition = "Bottom"
    lbres@lbLabelFont = 25
    lbres@lbTitleFontHeightF = 0.010
    lbres@lbTitleOffsetF = 0.2
    lbres@lbTitleExtentF = 0.25

    ;create height diff labelbar
    lbres3 = lbres
    lbres3@vpXF = 0.07
    lbres3@vpYF = 0.56
    lbres3@vpWidthF = 0.38
    lbres3@vpHeightF= 0.045

    lbres3@lbFillColors  := hgt_colors
    lbres3@lbTitleString = "~F25~GHT differences at 500 hPa (gpm)";optional
    lbres3@lbLabelStride = 1
    nboxes := dimsizes(hgt_colors)
    lbid_hdiff = gsn_create_labelbar(wks,nboxes,"" + hgt_cnlevels,lbres3)
    draw(lbid_hdiff)
    ;create raindiff diff labelbar
    lbres1 = lbres
    lbres1@vpXF = 0.57
    lbres1@vpYF = 0.56
    lbres1@vpWidthF = 0.38
    lbres1@vpHeightF= 0.045

    lbres1@lbFillColors  := rain_diff_colors
    lbres1@lbTitleString = "~F25~Rainfall differences (mm)";optional
    lbres1@lbLabelStride = 5
    nboxes := dimsizes(rain_diff_colors)
    lbid_rdiff = gsn_create_labelbar(wks,nboxes,"" + rain_diff_levels,lbres1)
    draw(lbid_rdiff)

    ;create qv diff labelbar
    lbres4 = lbres
    lbres4@vpXF = 0.32
    lbres4@vpYF = 0.16
    lbres4@vpWidthF = 0.4
    lbres4@vpHeightF= 0.05

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
    resP@gsnPanelXWhiteSpacePercent = 5
    resP@gsnPanelYWhiteSpacePercent = 14
    resP@gsnPanelBottom = 0.06
    ;resP@gsnPanelTop = 0.99
    resP@gsnPanelDebug = True
    ;drawNDCGrid(wks)
    gsn_panel(wks,contour,(/2,1/),resP)

;-----------------------------
    wallClockElapseTime(wcStrtGraphics, "Graphics", 0)
    wallClockElapseTime(wcStrt, "Processing and Graphics", 0)
end
