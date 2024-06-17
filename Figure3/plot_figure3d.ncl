begin
    print_clock("start")
    data_path = "../data/Figure3/circulation/"
    case_list = (/"CTL","RM_THQ"/)
    Re = get_sphere_radius()
    height_suffix = "/height_500hPa.nc"
    rainnc_suffix = "/rainnc_hr.nc"
    rainc_suffix = "/rainc_hr.nc"

    uzonal_suffix = "/ERA5/uzonal_500hPa.nc"
    umeridional_suffix = "/ERA5/umeridional_500hPa.nc"
    qv_suffix = "/ERA5/qv.nc"

    ;read geopotential height
    height_CTL_fi = addfile(data_path + case_list(0) + height_suffix, "r")
    height_CTL = height_CTL_fi->height_500hPa
    height_CTL_fix = Re*height_CTL/(Re + height_CTL)
    height_THQ_fi = addfile(data_path + case_list(1) + height_suffix, "r")
    height_THQ = height_THQ_fi->height_500hPa
    height_THQ_fix = Re*height_THQ/(Re + height_THQ)

    height_diff = height_CTL - height_THQ

    ;read rainfall
    rainnc_CTL_fi = addfile(data_path + case_list(0) + rainnc_suffix, "r")
    rainc_CTL_fi = addfile(data_path + case_list(0) + rainc_suffix, "r")
    rain_CTL = (rainnc_CTL_fi->rainnc_hr + rainc_CTL_fi->rainc_hr)*72
    rainnc_THQ_fi = addfile(data_path + case_list(1) + rainnc_suffix, "r")
    rainc_THQ_fi = addfile(data_path + case_list(1) + rainc_suffix, "r")
    rian_THQ = (rainnc_THQ_fi->rainnc_hr + rainc_THQ_fi->rainc_hr)*72

    rain_diff = rain_CTL - rian_THQ


    ;read wind
    uzonal_CTL_fi = addfile(data_path + case_list(0) + uzonal_suffix, "r")
    uzonal_CTL = uzonal_CTL_fi->uzonal_500hPa
    uzonal_THQ_fi = addfile(data_path + case_list(1) + uzonal_suffix, "r")
    uzonal_THQ = uzonal_THQ_fi->uzonal_500hPa

    umeridional_CTL_fi = addfile(data_path + case_list(0) + umeridional_suffix, "r")
    umeridional_CTL = umeridional_CTL_fi->umeridional_500hPa
    umeridional_THQ_fi = addfile(data_path + case_list(1) + umeridional_suffix, "r")
    umeridional_THQ = umeridional_THQ_fi->umeridional_500hPa

    ;read qv
    qv_CTL_fi = addfile(data_path + case_list(0) + qv_suffix, "r")
    qv_CTL = qv_CTL_fi->qv({50000},:,:)
    qv_THQ_fi = addfile(data_path + case_list(1) + qv_suffix, "r")
    qv_THQ = qv_THQ_fi->qv({50000},:,:)


    qu_diff = (qv_CTL*uzonal_CTL - qv_THQ*uzonal_THQ)*1e3
    copy_VarCoords(qv_CTL, qu_diff)
    qv_diff = (qv_CTL*umeridional_CTL - qv_THQ*umeridional_THQ)*1e3
    copy_VarCoords(qv_CTL, qv_diff)

    static_fi = addfile("../data/Figure3/cell_fill.nc", "r")
    latCell = static_fi->latCell
    lonCell = static_fi->lonCell

;---Graphics------------------
    minlat = 31
    maxlat = 50
    minlon = 105
    maxlon = 129
    printMinMax(height_diff,1)

    ;***prepare for plot***
    N_res = 2
    wks_type = "png"
    wks_type@wkWidth  = 1024*N_res;
    wks_type@wkHeight = 1024*N_res

    cnlevels = fspan(-300,300,51); rain difference
    ;cnlevels = fspan(-50,50,51); height difference
    ;rain_cmap =  read_colormap_file("MPL_RdBu")
    ;printVarSummary(rain_cmap)
    ;colors = new((/52,4/),"float")
    ;colors = rain_cmap(62-25*2:64+25*2:2,:)
    ;colors = rain_cmap(12:114:-2,:)

    rain_cmap =  read_colormap_file("MPL_PRGn")
    ;printVarSummary(rain_cmap)
    colors = new((/52,4/),"float")
    colors = rain_cmap(12:114:-2,:)

    ;***resources for plot***
    res             = True
    ;res@gsFont = "times-roman";Time Roman
    res@gsnDraw     = False
    res@gsnFrame    = False
    res@gsnMaximize = False
    ;res@gsnBoxMargin = 0.05
    res@gsnAddCyclic= False

    res@tmXTOn   = False
    res@tmYROn   = False

    res@gsnStringFont = 25
    res@gsnRightString = ""
    res@gsnLeftString    = "(d) CTL - RM_THQ"
    res@gsnLeftStringFontHeightF = 0.02
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

    mpres@mpDataSetName            = "/storage/aemolcore02/jungu/Data/Earth..4/Earth..4"
    mpres@mpDataBaseVersion        = "MediumRes"
    mpres@mpOutlineOn              =  True
    mpres@mpOutlineSpecifiers        = (/"China","China:Provinces"/)
    mpres@mpLandFillColor            = "white"
    mpres@mpInlandWaterFillColor     = "white"
    mpres@mpOceanFillColor           = "white"
    mpres@mpFillBoundarySets         = "NoBoundaries"
    ;mpres@mpOutlineBoundarySets      = "NoBoundaries"
    mpres@mpOutlineBoundarySets      = "Geophysical"
    mpres@mpNationalLineColor        = "black"
    mpres@mpProvincialLineColor      = "black"
    mpres@mpGeophysicalLineColor     = "black"
    mpres@mpNationalLineThicknessF   = 4*N_res
    mpres@mpProvincialLineThicknessF = 2*N_res
    mpres@mpGeophysicalLineThicknessF = 2*N_res

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
    mpres@tmXBValues = fspan(105,130,6)
    mpres@tmXBLabels = mpres@tmXBValues + "~S~o~N~E"
    mpres@tmXBMinorValues = ispan(105,130,1)

    mpres@tmYLMode = "Explicit"
    mpres@tmYLValues = fspan(30,50,5)
    mpres@tmYLLabels = mpres@tmYLValues + "~S~o~N~N"
    mpres@tmYLMinorValues = ispan(26,50,1)


    cnres = res
    cnres@gsnLeftString = ""
    cnres@cnFillDrawOrder = "PostDraw"
    cnres@cnFillOn  = False
    cnres@cnLinesOn = True
    cnres@cnLevelSelectionMode = "ExplicitLevels"
    cnres@cnLevels = (/588/)*10
    cnres@sfXArray = lonCell
    cnres@sfYArray = latCell

    ;Set some resources for color contour lines
    ;cnres@cnMonoLineThickness   = True;Important
    cnres@cnLineThicknessF = 7*N_res
    ;cnres@cnLineLabelFontHeightF=0.01
    ;cnres@cnMonoLineColor  = True;Important
    ;cnres@cnMonoLineDashPattern = True
    cnres@cnLineDashPattern = 0
    cnres@cnInfoLabelOn = False
    cnres@cnLineLabelFont = 25
    cnres@cnLineLabelsOn = False


    sdres = mpres
    sdres@cnFillDrawOrder = "Draw"
    sdres@cnFillOn = True
    sdres@cnLinesOn = False
    sdres@cnInfoLabelOn   = False
    sdres@cnLineLabelsOn  = False

    sdres@cnFillMode = "RasterFill"
    sdres@trGridType = "TriangularMesh"
    ;sdres@cnRasterSmoothingOn = True
    sdres@sfXArray =lonCell
    sdres@sfYArray =latCell

    sdres@cnLevelSelectionMode = "ExplicitLevels"
    sdres@cnLevels        = cnlevels
    sdres@cnFillColors    = colors

    sdres@lbLabelBarOn    = False

    vcres                       = res
    vcres@gsnLeftString  = ""
    vcres@vcGlyphStyle          = "LineArrow"
    ;vcres@vcGlyphStyle          = "CurlyVector"
    vcres@vcRefLengthF          = 0.03
    vcres@vcLineArrowColor      = "Black"
    vcres@vcMinDistanceF        = 0.023          ; set to small value to thin the vectors.
    vcres@vcLineArrowThicknessF = 3.            ; make the vectors thicker.
    vcres@vcVectorDrawOrder     = "PostDraw"

    vcres@vcRefAnnoOn               = True
    vcres@vcRefMagnitudeF           = 50.0
    vcres@vcRefAnnoString1          = "~F25~50"
    vcres@vcRefLengthF              = 0.03   ; define length of vec ref
    vcres@vcRefAnnoFontHeightF      = 0.015
    vcres@vcRefAnnoFontThicknessF   = 1.
    vcres@vcRefAnnoSide             = "Top"
    vcres@vcRefAnnoString2On        = True
    vcres@vcRefAnnoString2          = "~F25~g/kg m/s"
    vcres@vcRefAnnoPerimOn          = False
    vcres@vcRefAnnoOrthogonalPosF   = -0.188
    ;vcres@vcRefAnnoParallelPosF     = 0.999
    vcres@vcRefAnnoBackgroundColor  = "white"

    ;vcres@gsnRightString             = "~F25~Wind[m/s]"
    ;vcres@gsnRightStringFontHeightF  = 0.017
;***loop for draw&&frame
    wks = gsn_open_wks(wks_type, "Figure3d")
    ; Plot
    shade = gsn_csm_contour_map(wks,rain_diff,sdres)
    cnres@cnLineColor     = "Violetred"
    contour_ctl = gsn_csm_contour(wks,height_CTL_fix,cnres)
    cnres@cnLineColor     = "dodgerblue"
    contour_thq = gsn_csm_contour(wks,height_THQ_fix,cnres)
    vector  = gsn_csm_vector(wks,qu_diff,qv_diff,vcres)

    overlay(shade,contour_ctl)
    overlay(shade,contour_thq)
    overlay(shade,vector)
    print("***overlay finished***")
    box_lat = (/35,35,43,43,35/)
    box_lon = (/112,123,123,112,112/)
    plres   = True
    plres@gsLineDashPattern = 0
    plres@gsLineColor = "Red"
    plres@gsLineThicknessF = 10*N_res
    box = gsn_add_polyline(wks, shade, box_lon, box_lat, plres)
    draw(shade)

;Create common label
    lbres = True
    lbres@vpXF = 0.125
    lbres@vpYF = 0.16
    lbres@vpWidthF = 0.75
    lbres@vpHeightF= 0.08

    lbres@lbPerimOn = False
    lbres@lbBoxLinesOn = False
    lbres@lbBoxLineThicknessF = 1.2*N_res
    lbres@lbBoxSeparatorLinesOn = False
    lbres@lbOrientation = "Horizontal"
    lbres@lbFillColors  = colors
    lbres@lbMonoFillPattern = True
    lbres@lbLabelFontHeightF = 0.017
    lbres@lbLabelAlignment   = "InteriorEdges"
    lbres@lbTitleJust = "TopCenter"
    lbres@lbTitleFontHeightF = 0.018
    lbres@lbTitleOffsetF = 0.2
    lbres@lbTitleExtentF = 0.25
    lbres@lbTitlePosition = "Bottom"
    lbres@lbTitleString = "~F25~ Rainfall difference (mm)"
    lbres@lbLabelStride = 5
    nboxes = dimsizes(colors)
    labels = "~F25~"+cnlevels
    lbid_wspd = gsn_create_labelbar(wks,nboxes,labels,lbres)
    draw(lbid_wspd)
    ;drawNDCGrid(wks)
    frame(wks)
    print_clock("End")
end 

