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

    ;select region
    minlat = 35.
    maxlat = 43.
    minlon = 105.
    maxlon = 130

;-----------------------------
    wallClockElapseTime(wcStrt, "Processing", 0)
    wcStrtGraphics = systemfunc(date_cmd)
;---Graphics------------------
    wks_name = "Figure1b"
    wks_type = "png"
    N_res = 2
    wks_type@wkHeight = 1024*N_res
    wks_type@wkWidth  = 1024*N_res
    wks = gsn_open_wks(wks_type, wks_name)

    ;set uniform resources
    res = True
    res@gsnDraw = False
    res@gsnFrame= False
    res@gsnAddCyclic = False
    res@gsnMaximize  = False
    res@gsnLeftString =""
    res@gsnRightString =""
    res@gsnLeftStringFontHeightF = 0.03
    res@gsnLeftStringOrthogonalPosF = 0.005
    res@gsnCenterStringOrthogonalPosF = 0.005

    res@vpHeightF = 0.8
    res@vpWidthF  = 0.8
    res@vpXF = 0.1
    res@vpYF = 0.95

    ;tickmark
    res@tmXTOn = False
    res@tmYROn = False
    res@tmBorderThicknessF = 4.5*N_res
    res@tmYLMajorThicknessF = 3.5*N_res
    res@tmYLMinorThicknessF = 3.5*N_res
    res@tmYLMajorLengthF    = 0.01
    res@tmYLMinorLengthF    = 0.006
    res@tmXBMajorThicknessF = 3.5*N_res
    res@tmXBMinorThicknessF = 3.5*N_res
    res@tmXBMajorLengthF    = 0.01
    res@tmXBMinorLengthF    = 0.006
    ;res@tmXBMinorOn = False
    ;res@tmYLMinorOn = False
    ;res@tmXBLabelDeltaF = -0.5
    ;res@tmYLLabelDeltaF = -0.5
    res@tmXBLabelFontHeightF = 0.017
    res@tmYLLabelFontHeightF = 0.017
    res@tmXBLabelFont = 25
    res@tmYLLabelFont = 25

    minlat = 22.5
    maxlat = 55
    minlon = 84
    maxlon = 124

    mpres = res
    mpres@mpProjection = "CylindricalEquidistant" ;default projection to draw rectangular box
    mpres@mpLimitMode   	= "LatLon"
    mpres@mpMinLatF = minlat
    mpres@mpMaxLatF = maxlat
    mpres@mpMinLonF = minlon
    mpres@mpMaxLonF = maxlon

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
    mpres@mpGeophysicalLineThicknessF= 2*N_res
    mpres@mpNationalLineThicknessF   = 4*N_res
    mpres@mpProvincialLineThicknessF = 2*N_res

    mpres@tmXBMode = "Explicit"
    mpres@tmXBValues = ispan(80,140,10)
    mpres@tmXBMinorValues = ispan(80,140,5)
    mpres@tmXBLabels = abs(mpres@tmXBValues) + "~S~o~N~E"
    mpres@tmYLMode = "Explicit"
    mpres@tmYLValues = ispan(20,55,10)
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
    ;cmap = read_colormap_file("MPL_RdBu")
    ;colors = new((/42,4/), "float")
    ;colors = cmap(63-62:64+60:-3,:);
    ;cnlevels = fspan(-1,1,41)
    cmap = read_colormap_file("MPL_RdBu")
    colors = new((/42,4/), "float")
    colors = cmap(63-62:64+60:-3,:);
    cnlevels = fspan(-1,1,41)
    cnres@cnLevels        := cnlevels
    cnres@cnFillColors    := colors
    cnres@lbLabelBarOn    = False

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


    ;cnres@gsnLeftString = "~F26~a"
    ;cnres@gsnCenterString = "~F26~2-m temperature trend"
    ;contour(0) = gsn_csm_contour_map(wks, t2m, cnres)
    ;shade(0) = gsn_csm_contour(wks, t2m_prob, sdres)
    ;overlay(contour(0), shade(0))
    cnres@gsnLeftString = "~F26~b"
    cnres@gsnCenterString = "~F26~500-hPa temperature trend"
    contour = gsn_csm_contour_map(wks, t_500hPa, cnres)
    shade = gsn_csm_contour(wks, t_500hPa_prob, sdres)
    overlay(contour, shade)


    box_lat = (/35,35,50,50,35/)
    box_lon = (/85,115,115,85,85/)
    plres   = True
    plres@gsLineDashPattern = 0
    plres@gsLineColor = "dimgray"
    plres@gsLineThicknessF = 7*N_res
    box0 = gsn_add_polyline(wks, shade, box_lon, box_lat, plres)
    ;box1 = gsn_add_polyline(wks, shade(1), box_lon, box_lat, plres)

    box_lat := (/35,35,41.5,41.5,35/)
    box_lon := (/112.5,117.5,117.5,112.5,112.5/)
    plres@gsLineThicknessF = 5*N_res
    plres@gsLineColor = "Black"
    box = gsn_add_polyline(wks, shade, box_lon, box_lat, plres)

    ;Create common label
    lbres = True
    lbres@lbPerimOn = False
    lbres@lbBoxLinesOn = True
    lbres@lbBoxSeparatorLinesOn = False
    ;lbres@lbBoxLineThicknessF = 1.2*N_res
    lbres@lbOrientation = "horizontal"
    lbres@lbMonoFillPattern = True
    lbres@lbLabelFont = 25
    lbres@lbLabelFontHeightF = 0.017
    lbres@lbLabelAlignment   = "InteriorEdges"
    lbres@lbTitlePosition = "Bottom"
    lbres@lbTitleFontHeightF = 0.017
    lbres@lbTitleOffsetF = 0.2
    lbres@lbTitleExtentF = 0.25

    ;create trend labelbar
    lbres1 = lbres
    lbres1@vpXF = 0.125
    lbres1@vpYF = 0.16
    lbres1@vpWidthF = 0.75
    lbres1@vpHeightF= 0.08

    lbres1@lbFillColors  := colors
    lbres1@lbTitleString = "~F25~Temperature trend (K/decade)";optional
    lbres1@lbLabelStride = 4
    lbid_trend = gsn_create_labelbar(wks,dimsizes(colors),cnlevels,lbres1)
    draw(lbid_trend)
    draw(contour)
    frame(wks)

    ;resP = True
    ;resP@gsnPanelLabelBar = False
    ;resP@gsnMaximize = True
    ;resP@gsnPanelRowSpec = True
    ;resP@gsnPanelCenter = True
    ;;resP@gsnPanelDebug = True
    ;resP@gsnPanelYWhiteSpacePercent = 10
    ;resP@gsnPanelBottom = 0.06
    ;;resP@gsnPanelTop = 0.99
    ;gsn_panel(wks,contour,(/2/),resP)
    ;drawNDCGrid(wks)

;-----------------------------
    wallClockElapseTime(wcStrtGraphics, "Graphics", 0)
    wallClockElapseTime(wcStrt, "Processing and Graphics", 0)
end
