begin
    print_clock("start")
;---Processing----------------
    data_path = "../data/Figure1/"
    CHM_fi = addfile(data_path + "CHM_PRE_0.1dg_19612022.nc", "r")
    years = CHM_fi->years
    hours = CHM_fi->time
    lat = CHM_fi->latitude
    lon = CHM_fi->longitude
    pre = CHM_fi->pre
    delete(pre@missing_value)

    time_days = cd_convert(hours,"days since 1961-01-01 00:00:00")
    yyyymmdd = cd_calendar(time_days, -2)
    ind_start = ind(yyyymmdd .eq. "19810101")
    ind_end = ind(yyyymmdd .eq. "20201231")
    print("start: " + ind_start + " end: " + ind_end)
    pre@_FillValue = -99.9
    pre_select = pre(ind_start:ind_end,:,:)
    pre_avg = dim_avg_n(pre_select,0)
    pre_avg_3day = pre_avg*3
    copy_VarCoords(pre(0,:,:),pre_avg_3day)

    CLDAS_fi = addfile(data_path + "regrid/CLDAS_Doksuri_stod_CHM.nc","r")
    rain_3day = CLDAS_fi->rain_3day
    rain_3day = where(ismissing(rain_3day),-99.9,rain_3day)
    rain_3day@missing_value = -99.9
    rain_3day@_FillValue = -99.9

    anomaly = rain_3day - pre_avg_3day
    copy_VarCoords(rain_3day,anomaly)
    printMinMax(anomaly,1)
;---Graphics------------------
    minlat = 25.5
    maxlat = 45
    minlon = 100
    maxlon = 124
    ;minlat = 27
    ;maxlat = 43
    ;minlon = 103
    ;maxlon = 127

    N_res = 2
    wks_type = "png"
    wks_type@wkWidth  = 1024*N_res;
    wks_type@wkHeight = 1024*N_res
    wks = gsn_open_wks(wks_type, "./Figure1a")

    cnlevels = fspan(-50,450,51)

    ;rain_cmap = read_colormap_file("rainfall1")
    ;colors = rain_cmap
    rain_cmap =  read_colormap_file("MPL_PRGn")
    printVarSummary(rain_cmap)
    colors = new((/52,4/),"float")
    colors(0:5,:) = rain_cmap(10:60:10,:)
    colors(6:51,:) = rain_cmap(75:120,:)
    ;colors(6:11,:) = rain_cmap(64:69,:)
    ;colors(12:17,:) = rain_cmap(72:77,:)
    ;colors(18:23,:) = rain_cmap(80:85,:)
    ;colors(24:29,:) = rain_cmap(88:93,:)
    ;colors(30:35,:) = rain_cmap(96:101,:)
    ;colors(36:41,:) = rain_cmap(104:109,:)
    ;colors(42:47,:) = rain_cmap(112:117,:)
    ;colors(48:51,:) = rain_cmap(120:123,:)
    ;colors = rain_cmap(53-10:74+40,:)

    res = True
    res@gsnDraw = False
    res@gsnFrame= False
    res@gsnAddCyclic = False
    res@gsnMaximize  = False
    res@gsnStringFont = 25
    res@gsnLeftString            = "(a) Precipitation anomaly (mm)"
    res@gsnLeftStringFontHeightF = 0.02
    res@gsnRightString            = ""
    res@gsnLeftStringOrthogonalPosF = 0.005

    res@vpHeightF = 0.8
    res@vpWidthF  = 0.8
    res@vpXF = 0.1
    res@vpYF = 0.95

    mpres = res
    mpres@mpProjection = "CylindricalEquidistant" ;default projection to draw rectangular box

    mpres@mpLimitMode   	= "LatLon"
    mpres@mpMinLatF = minlat
    mpres@mpMaxLatF = maxlat
    mpres@mpMinLonF = minlon
    mpres@mpMaxLonF = maxlon

    mpres@mpDataSetName     = "/storage/aemolcore02/jungu/Data/Earth..4/Earth..4"
    mpres@mpDataBaseVersion = "MediumRes"
    ;mpres@mpAreaMaskingOn = True
    mpres@mpOutlineSpecifiers        = (/"China","China:Provinces"/)
    mpres@mpLandFillColor            = "white"
    mpres@mpInlandWaterFillColor     = "white"
    mpres@mpOceanFillColor           = "white"
    mpres@mpFillBoundarySets         = "NoBoundaries"
    mpres@mpOutlineBoundarySets      = "NoBoundaries"
    mpres@mpNationalLineColor        = "black"
    mpres@mpProvincialLineColor      = "black"
    mpres@mpGeophysicalLineColor     = "black"
    mpres@mpNationalLineThicknessF   = 4*N_res
    mpres@mpProvincialLineThicknessF = 2*N_res
    mpres@mpGeophysicalLineThicknessF = 2*N_res

    ;mpres@pmTickMarkDisplayMode = "Always"
    mpres@tmXTOn = False
    mpres@tmYROn = False
    mpres@tmBorderThicknessF = 4.5*N_res
    mpres@tmYLMajorThicknessF = 3.5*N_res
    mpres@tmYLMinorThicknessF = 3.5*N_res
    mpres@tmYLMajorLengthF    = 0.01
    mpres@tmYLMinorLengthF    = 0.006
    mpres@tmXBMajorThicknessF = 3.5*N_res
    mpres@tmXBMinorThicknessF = 3.5*N_res
    mpres@tmXBMajorLengthF    = 0.01
    mpres@tmXBMinorLengthF    = 0.006
    mpres@tmXBLabelFont = 25
    mpres@tmYLLabelFont = 25

    mpres@tmXBMinorOn = True
    mpres@tmYLMinorOn = True
    ;mpres@tmXBLabelDeltaF = -0.5
    ;mpres@tmYLLabelDeltaF = -0.5
    mpres@tmXBLabelFontHeightF = 0.017
    mpres@tmYLLabelFontHeightF = 0.017

    mpres@tmXBMode = "Explicit"
    mpres@tmXBValues = fspan(100,120,5)
    mpres@tmXBLabels = mpres@tmXBValues + "~S~o~N~E"
    mpres@tmXBMinorValues = ispan(100,124,1)

    mpres@tmYLMode = "Explicit"
    mpres@tmYLValues = fspan(30,45,4)
    mpres@tmYLLabels = mpres@tmYLValues + "~S~o~N~N"
    mpres@tmYLMinorValues = ispan(26,45,1)

    cnres = mpres
    cnres@cnFillDrawOrder = "Draw"
    cnres@cnFillOn = True
    cnres@cnLinesOn = False
    cnres@cnInfoLabelOn   = False
    cnres@cnLineLabelsOn  = False

    cnres@cnFillMode = "RasterFill"
    cnres@cnRasterSmoothingOn = True

    cnres@cnLevelSelectionMode = "ExplicitLevels"
    cnres@cnLevels        = cnlevels
    cnres@cnFillColors    = colors

    cnres@lbLabelBarOn    = False

    ;-------Plot---------
    contour = gsn_csm_contour_map(wks,anomaly,cnres)

;Create common label
    lbres = True
    lbres@vpXF = 0.125
    lbres@vpYF = 0.16
    lbres@vpWidthF = 0.75
    lbres@vpHeightF= 0.08

    lbres@lbPerimOn = False
    lbres@lbBoxLinesOn = False
    lbres@lbBoxSeparatorLinesOn = False
    ;lbres@lbBoxLineThicknessF = 1.2*N_res
    lbres@lbOrientation = "Horizontal"
    lbres@lbFillColors  = colors
    lbres@lbMonoFillPattern = True
    lbres@lbLabelFontHeightF = 0.017
    lbres@lbLabelAlignment   = "InteriorEdges"
    lbres@lbTitleJust = "TopCenter"
    lbres@lbTitleFontHeightF = 0.014
    lbres@lbTitleOffsetF = 0.2
    lbres@lbTitleExtentF = 0.25
    lbres@lbTitleString = "";optional
    lbres@lbTitlePosition = "Bottom"
    lbres@lbLabelStride = 5
    nboxes = dimsizes(colors)
    labels = "~F25~"+cnlevels
    lbid_mslp = gsn_create_labelbar(wks,nboxes,labels,lbres)
    draw(lbid_mslp)

    plres   = True
    plres@gsLineDashPattern = 0
    plres@gsLineThicknessF  = 4*N_res
    plres@gsLineColor = "Black"

    box_lat = (/35,35,41.5,41.5,35/)
    box_lon = (/112,117,117,112,112/)
    plres@gsLineThicknessF = 10
    box = gsn_add_polyline(wks, contour, box_lon, box_lat, plres)

    draw(contour)
    frame(wks)
    print_clock("finish")
;-----------------------------
end
