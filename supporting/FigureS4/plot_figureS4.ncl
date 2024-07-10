begin
    print_clock("start")
    data_path = "../..//data/Figure3/circulation/"
    case_list = (/"CTL","RM_TH","RM_Q","RM_T","RM_T_NO_MP"/)
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

    height_exps = new((/4,785410/),double)

    height_TH_fi = addfile(data_path + case_list(1) + height_suffix, "r")
    height_TH = height_TH_fi->height_500hPa
    height_exps(0,:) = Re*height_TH/(Re + height_TH)
    height_Q_fi = addfile(data_path + case_list(2) + height_suffix, "r")
    height_Q = height_Q_fi->height_500hPa
    height_exps(1,:) = Re*height_Q/(Re + height_Q)
    height_T_fi = addfile(data_path + case_list(3) + height_suffix, "r")
    height_T = height_T_fi->height_500hPa
    height_exps(2,:) = Re*height_T/(Re + height_T)
    height_T_NO_MP_fi = addfile(data_path + case_list(4) + height_suffix, "r")
    height_T_NO_MP = height_T_NO_MP_fi->height_500hPa
    height_exps(3,:) = Re*height_T_NO_MP/(Re + height_T_NO_MP)

    ;read rainfall
    rainnc_CTL_fi = addfile(data_path + case_list(0) + rainnc_suffix, "r")
    rainc_CTL_fi = addfile(data_path + case_list(0) + rainc_suffix, "r")
    rain_CTL = (rainnc_CTL_fi->rainnc_hr + rainc_CTL_fi->rainc_hr)*72

    rain_diff_exps = new((/4,785410/),double)

    rainnc_TH_fi = addfile(data_path + case_list(1) + rainnc_suffix, "r")
    rainc_TH_fi = addfile(data_path + case_list(1) + rainc_suffix, "r")
    rian_TH = (rainnc_TH_fi->rainnc_hr + rainc_TH_fi->rainc_hr)*72
    rain_diff_exps(0,:) = rain_CTL - rian_TH

    rainnc_Q_fi = addfile(data_path + case_list(2) + rainnc_suffix, "r")
    rainc_Q_fi = addfile(data_path + case_list(2) + rainc_suffix, "r")
    rian_Q = (rainnc_Q_fi->rainnc_hr + rainc_Q_fi->rainc_hr)*72
    rain_diff_exps(1,:) = rain_CTL - rian_Q

    rainnc_T_fi = addfile(data_path + case_list(3) + rainnc_suffix, "r")
    rainc_T_fi = addfile(data_path + case_list(3) + rainc_suffix, "r")
    rian_T = (rainnc_T_fi->rainnc_hr + rainc_T_fi->rainc_hr)*72
    rain_diff_exps(2,:) = rain_CTL - rian_T

    rainnc_T_NO_MP_fi = addfile(data_path + case_list(4) + rainnc_suffix, "r")
    rainc_T_NO_MP_fi = addfile(data_path + case_list(4) + rainc_suffix, "r")
    rian_T_NO_MP = (rainnc_T_NO_MP_fi->rainnc_hr + rainc_T_NO_MP_fi->rainc_hr)*72
    rain_diff_exps(3,:) = rain_CTL - rian_T_NO_MP

    ;read wind
    uzonal_CTL_fi = addfile(data_path + case_list(0) + uzonal_suffix, "r")
    uzonal_CTL = uzonal_CTL_fi->uzonal_500hPa
    uzonal_TH_fi = addfile(data_path + case_list(1) + uzonal_suffix, "r")
    uzonal_TH = uzonal_TH_fi->uzonal_500hPa
    uzonal_Q_fi = addfile(data_path + case_list(2) + uzonal_suffix, "r")
    uzonal_Q = uzonal_Q_fi->uzonal_500hPa
    uzonal_T_fi = addfile(data_path + case_list(3) + uzonal_suffix, "r")
    uzonal_T = uzonal_T_fi->uzonal_500hPa
    uzonal_T_NO_MP_fi = addfile(data_path + case_list(4) + uzonal_suffix, "r")
    uzonal_T_NO_MP = uzonal_T_NO_MP_fi->uzonal_500hPa

    umeridional_CTL_fi = addfile(data_path + case_list(0) + umeridional_suffix, "r")
    umeridional_CTL = umeridional_CTL_fi->umeridional_500hPa
    umeridional_TH_fi = addfile(data_path + case_list(1) + umeridional_suffix, "r")
    umeridional_TH = umeridional_TH_fi->umeridional_500hPa
    umeridional_Q_fi = addfile(data_path + case_list(2) + umeridional_suffix, "r")
    umeridional_Q = umeridional_Q_fi->umeridional_500hPa
    umeridional_T_fi = addfile(data_path + case_list(3) + umeridional_suffix, "r")
    umeridional_T = umeridional_T_fi->umeridional_500hPa
    umeridional_T_NO_MP_fi = addfile(data_path + case_list(4) + umeridional_suffix, "r")
    umeridional_T_NO_MP = umeridional_T_NO_MP_fi->umeridional_500hPa

    ;read qv
    qv_CTL_fi = addfile(data_path + case_list(0) + qv_suffix, "r")
    qv_CTL = qv_CTL_fi->qv({50000},:,:)
    qv_TH_fi = addfile(data_path + case_list(1) + qv_suffix, "r")
    qv_TH = qv_TH_fi->qv({50000},:,:)
    qv_Q_fi = addfile(data_path + case_list(2) + qv_suffix, "r")
    qv_Q = qv_Q_fi->qv({50000},:,:)
    qv_T_fi = addfile(data_path + case_list(3) + qv_suffix, "r")
    qv_T = qv_T_fi->qv({50000},:,:)
    qv_T_NO_MP_fi = addfile(data_path + case_list(4) + qv_suffix, "r")
    qv_T_NO_MP = qv_T_NO_MP_fi->qv({50000},:,:)

    qu_diff_exps = new((/4,721,1440/),double)
    qv_diff_exps = new((/4,721,1440/),double)
    qu_diff_exps!0 = "case"
    qu_diff_exps!1 = "lat"
    qu_diff_exps!2 = "lon"
    qu_diff_exps&lat = uzonal_CTL&lat
    qu_diff_exps&lon = umeridional_CTL&lon
    copy_VarMeta(qu_diff_exps, qv_diff_exps)


    qu_diff_exps(0,:,:) = (qv_CTL*uzonal_CTL - qv_TH*uzonal_TH)*1e3
    qv_diff_exps(0,:,:) = (qv_CTL*umeridional_CTL - qv_TH*umeridional_TH)*1e3

    qu_diff_exps(1,:,:) = (qv_CTL*uzonal_CTL - qv_Q*uzonal_Q)*1e3
    qv_diff_exps(1,:,:) = (qv_CTL*umeridional_CTL - qv_Q*umeridional_Q)*1e3

    qu_diff_exps(2,:,:) = (qv_CTL*uzonal_CTL - qv_T*uzonal_T)*1e3
    qv_diff_exps(2,:,:) =(qv_CTL*umeridional_CTL - qv_T*umeridional_T)*1e3

    qu_diff_exps(3,:,:) = (qv_CTL*uzonal_CTL - qv_T_NO_MP*uzonal_T_NO_MP)*1e3
    qv_diff_exps(3,:,:) = (qv_CTL*umeridional_CTL - qv_T_NO_MP*umeridional_T_NO_MP)*1e3


    static_fi = addfile("../../data/Figure3/cell_fill.nc", "r")
    latCell = static_fi->latCell
    lonCell = static_fi->lonCell

;---Graphics------------------
    minlat = 31
    maxlat = 50
    minlon = 105
    maxlon = 129

    ;***prepare for plot***
    N_res = 4
    wks_type = "png"
    wks_type@wkWidth  = 1024*N_res;
    wks_type@wkHeight = 1024*N_res

    cnlevels = fspan(-300,300,51); rain difference

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
    ;res@gsnLeftString    = "(d) CTL - RM_THQ"
    ;res@gsnLeftStringFontHeightF = 0.02
    ;res@gsnLeftStringOrthogonalPosF = 0.005

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
    vcres@vcLineArrowThicknessF = 2.*N_res            ; make the vectors thicker.
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
    vcres@vcRefAnnoOrthogonalPosF   = -0.19
    vcres@vcRefAnnoParallelPosF     = 0.998
    vcres@vcRefAnnoBackgroundColor  = "white"

    ;vcres@gsnRightString             = "~F25~Wind[m/s]"
    ;vcres@gsnRightStringFontHeightF  = 0.017
;***loop for draw&&frame
    wks = gsn_open_wks(wks_type, "FigureS4")
    shade = new(4,graphic)
    contour_ctl = new(4,graphic)
    contour_thq = new(4,graphic)
    vector      = new(4,graphic)

    ; Plot
    left_string = (/"(a) CTL - RM_TH", "(b) CTL - RM_Q", "(c) CTL - RM_T", "(d) CTL - RM_T_NO_MP"/)
    ln_colors = (/"goldenrod","forestgreen","turquoise","darkslateblue"/)
    cnres@gsnLeftStringFontHeightF = 0.03
    cnres@gsnLeftStringOrthogonalPosF = 0.005
    do iplot =0, 3
        shade(iplot) = gsn_csm_contour_map(wks,rain_diff_exps(iplot,:),sdres)
        cnres@cnLineColor     = "Violetred"
        cnres@gsnLeftString    = left_string(iplot)
        contour_ctl(iplot) = gsn_csm_contour(wks,height_CTL_fix,cnres)
        cnres@cnLineColor     = ln_colors(iplot)
        contour_thq(iplot) = gsn_csm_contour(wks,height_exps(iplot,:),cnres)
        vector(iplot)  = gsn_csm_vector(wks,qu_diff_exps(iplot,:,:),qv_diff_exps(iplot,:,:),vcres)
        overlay(shade(iplot),contour_ctl(iplot))
        overlay(shade(iplot),contour_thq(iplot))
        overlay(shade(iplot),vector(iplot))
        if (iplot .eq. 3)
            cnres@cnLineColor     = ln_colors(2)
            contour_add = gsn_csm_contour(wks, height_exps(2,:), cnres)
            overlay(shade(iplot), contour_add)
        end if
    end do

    print("***overlay finished***")
    box_lat = (/35,35,43,43,35/)
    box_lon = (/112,123,123,112,112/)
    plres   = True
    plres@gsLineDashPattern = 0
    plres@gsLineColor = "Red"
    plres@gsLineThicknessF = 10*N_res
    ;box = gsn_add_polyline(wks, shade, box_lon, box_lat, plres)
    ;draw(shade)

;Create common label
    lbres = True
    lbres@vpXF = 0.04
    lbres@vpYF = 0.11
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
    ;frame(wks)

    lnres = True
    lnres@gsLineThicknessF = 7*N_res
    lnres@gsLineDashPattern = 0
    txres = True
    txres@txFontHeightF = 0.013
    txres@txFont = 25
    txres@txJust = "CenterLeft"

    ln_x = 0.82
    ln_x2= 0.85
    item_y1 = 0.12
    item_y2 = 0.1
    item_y3 = 0.08
    item_y4 = 0.06
    item_y5 = 0.04

    lnres@gsLineColor = "Violetred"
    gsn_polyline_ndc(wks, (/ln_x,ln_x2/), (/item_y1,item_y1/), lnres)
    gsn_text_ndc(wks, "CTL", ln_x2+0.02, item_y1, txres)

    lnres@gsLineColor = "goldenrod"
    gsn_polyline_ndc(wks, (/ln_x,ln_x2/), (/item_y2,item_y2/), lnres)
    gsn_text_ndc(wks, "RM_TH", ln_x2+0.02, item_y2, txres)

    lnres@gsLineColor = "forestgreen"
    gsn_polyline_ndc(wks,  (/ln_x,ln_x2/), (/item_y3,item_y3/), lnres)
    gsn_text_ndc(wks, "RM_Q", ln_x2+0.02, item_y3, txres)

    lnres@gsLineColor = "turquoise"
    gsn_polyline_ndc(wks,  (/ln_x,ln_x2/), (/item_y4,item_y4/), lnres)
    gsn_text_ndc(wks, "RM_T", ln_x2+0.02, item_y4, txres)

    lnres@gsLineColor = "darkslateblue"
    gsn_polyline_ndc(wks, (/ln_x,ln_x2/), (/item_y5,item_y5/), lnres)
    gsn_text_ndc(wks, "RM_T_NO_MP", ln_x2+0.02, item_y5, txres)


    resP = True
    resP@gsnPanelLabelBar = False
    resP@gsnMaximize = True
    resP@gsnPanelRowSpec = True
    resP@gsnPanelCenter = True
    resP@gsnPanelBottom = 0.12
    resP@gsnPanelYWhiteSpacePercent = 5
    ;drawNDCGrid(wks)
    gsn_panel(wks,shade,(/2,2/),resP)

end 

