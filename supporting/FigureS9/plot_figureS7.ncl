begin
    dq = str_get_dq()
    date_cmd   = "date +" + dq + "%a %b %d %H:%M:%S %Z %Y" + dq
    wcStrt = systemfunc(date_cmd)
;---Processing----------------
    data_path = "../../data/"
    ;read trend pl file
    trend_pl_fi = addfile(data_path + "trend/Trend_pl.nc", "r")
    t_500hPa = trend_pl_fi->t({500},:,:)
    t_500hPa_prob = trend_pl_fi->t_prob({500},:,:)
    t_500hPa_rmt =  t_500hPa*43

    trend_pl_noMP_fi = addfile(data_path + "trend/Trend_pl_noMP.nc", "r")
    t_500hPa_noMP = trend_pl_noMP_fi->t({500},:,:)
    t_500hPa_noMP = t_500hPa_noMP*43;43 years


    t_500hPa_mp = t_500hPa_noMP
    t_500hPa_noMP_rmt = t_500hPa_rmt - t_500hPa_noMP

    copy_VarCoords(t_500hPa_prob, t_500hPa_rmt)              ; copy coordinate variables
    copy_VarCoords(t_500hPa_prob, t_500hPa_noMP_rmt)              ; copy coordinate variables
    copy_VarCoords(t_500hPa_prob, t_500hPa_mp)              ; copy coordinate variables

    ;read trend sfc file



    ;read static file
    static_fi = addfile("../../data/simulation/cell_fill.nc", "r")
    latCell = static_fi->latCell
    lonCell = static_fi->lonCell

    ;select region
    minlat = 35.
    maxlat = 43.
    minlon = 105.
    maxlon = 130
;-----------------------------
    wallClockElapseTime(wcStrt, "Processing", 0)
    wcStrtGraphics = systemfunc(date_cmd)
;---Graphics------------------
    wks_name = "FigureS9"
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
    ;res@gsnStringFont = 25
    res@gsnStringFontHeightF = 0.019
    res@gsnLeftString = ""
    res@gsnRightString= ""
    res@gsnLeftStringOrthogonalPosF = 0.005
    res@gsnCenterStringOrthogonalPosF = 0.005
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

    contour = new(2,graphic)

    cnres@gsnLeftString = "~F26~a    ~F25~CTL - RM_T"
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
    contour(0) = gsn_csm_contour_map(wks, t_500hPa_rmt, cnres)
    cnres@gsnLeftString = "~F26~b    ~F25~CTL - RM_T_MP"
    contour(1) = gsn_csm_contour_map(wks, t_500hPa_noMP_rmt, cnres)
    ;cnres@gsnLeftString = "(c) RM_T_NO_MP - RM_T"
    ;contour(2) = gsn_csm_contour_map(wks, t_500hPa_noMP_rmt, cnres)



    box_lat = (/35,35,50,50,35/)
    box_lon = (/85,115,115,85,85/)
    plres   = True
    plres@gsLineDashPattern = 0
    plres@gsLineColor = "dimgray"
    plres@gsLineThicknessF = 5*N_res
    box4 = gsn_add_polyline(wks, contour(0), box_lon, box_lat, plres)
    box2 = gsn_add_polyline(wks, contour(1), box_lon, box_lat, plres)
    ;box1 = gsn_add_polyline(wks, contour(2), box_lon, box_lat, plres)
    ;box3 = gsn_add_polyline(wks, contour(3), box_lon, box_lat, plres)

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

    ;create temperature difference labelbar
    lbres2 = lbres
    lbres2@vpXF = 0.2
    lbres2@vpYF = 0.34
    lbres2@vpWidthF = 0.6
    lbres2@vpHeightF= 0.05

    lbres2@lbFillColors  := t_diff_colors
    lbres2@lbTitleString = "~F25~Temperature differences at 500 hPa (K)";optional
    lbres2@lbLabelStride = 1
    nboxes := dimsizes(t_diff_colors)
    lbid_tdiff = gsn_create_labelbar(wks,nboxes,""+t_diff_cnlevels,lbres2)
    draw(lbid_tdiff)

    resP = True
    resP@gsnPanelLabelBar = False
    resP@gsnMaximize = True
    resP@gsnPanelRowSpec = True
    resP@gsnPanelCenter = True
    ;resP@gsnPanelDebug = True
    resP@gsnPanelYWhiteSpacePercent = 10
    resP@gsnPanelBottom = 0.06
    ;resP@gsnPanelTop = 0.99
    ;drawNDCGrid(wks)
    gsn_panel(wks,contour,(/2/),resP)

;-----------------------------
    wallClockElapseTime(wcStrtGraphics, "Graphics", 0)
    wallClockElapseTime(wcStrt, "Processing and Graphics", 0)
end
