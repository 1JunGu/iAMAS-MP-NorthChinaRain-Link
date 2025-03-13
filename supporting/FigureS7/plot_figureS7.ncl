begin
    dq = str_get_dq()
    date_cmd   = "date +" + dq + "%a %b %d %H:%M:%S %Z %Y" + dq
    wcStrt = systemfunc(date_cmd)
;---Processing----------------
    data_path = "/home/export/online1/mdt00/shisuan/swustc/jungu/MPAS/cases/2305Doksuri/EEA/1.Make_init/"
    ;read trend pl file
    trend_pl_fi = addfile(data_path + "/Trend_pl.nc", "r")
    t_500hPa = trend_pl_fi->t({500},:,:)
    t_500hPa_prob = trend_pl_fi->t_prob({500},:,:)
    t_500hPa =  t_500hPa*10
    t_500hPa@units = "K/decade"

    data_path = "./"

    trend_sfc_fi = addfile(data_path + "/Trend_sfc.nc", "r")
    t2m = trend_sfc_fi->t2m
    t2m_prob = trend_sfc_fi->t2m_prob
    t2m =  t2m*10
    t2m@units = "K/decade"

    case_list = (/"CTL","RM_T_MP"/)
    date_list = (/"2023-07-29","2023-07-30","2023-07-31","3day"/)
    data_out_path = "../../" + case_list + "/v4km/sep_vars_out/ensemble_0728_12/daily_avg/"

    rain_ctl_fi = addfile(data_out_path(0) + date_list(3) +  "/isobaric/height_isobaric.nc","r")
    ;rain_ctl_fi = addfiles(data_path(1) + date_list +  "/height_500hPa.nc","r")
    ;ListSetType(rain_ctl_fi, "join")
    ;height_ctl = rain_ctl_fi[:]->height_500hPa
    Re = get_sphere_radius()
    height_ctl = rain_ctl_fi->height(:,19)
    height_ctl = height_ctl*Re/(height_ctl+Re) ;convert to geopotential height

    rain_rm_t_mp_fi = addfile(data_out_path(1) + date_list(3) +  "/isobaric/height_isobaric.nc","r")
    ;rain_rm_t_mp_fi = addfiles(data_path(1) + date_list +  "/height_500hPa.nc","r")
    ;ListSetType(rain_rm_t_mp_fi, "join")
    ;height_rm_t_mp = rain_rm_t_mp_fi[:]->height_500hPa
    height_rm_t_mp = rain_rm_t_mp_fi->height(:,19)
    height_rm_t_mp = height_rm_t_mp*Re/(height_rm_t_mp+Re) ;convert to geopotential height

    ;read static file
    ;static_fi = addfile("../data/simulation/cell_fill.nc", "r")
    ;latCell = static_fi->latCell
    ;lonCell = static_fi->lonCell
    static_fi = addfile("/home/export/online1/mdt00/shisuan/swustc/jungu/MPAS/meshes/rotated_4-60km_28N117E_785410/init_static.nc","r")
    R2D = get_r2d("double")
    latCell = static_fi->latCell*R2D
    lonCell = static_fi->lonCell*R2D

    ;select region
    minlat = 35.
    maxlat = 43.
    minlon = 105.
    maxlon = 130

    index_region = ind(latCell.ge.minlat.and.latCell.le.maxlat.and.lonCell.ge.minlon.and.lonCell.le.maxlon)
    latCell_region = latCell(index_region)
    lonCell_region = lonCell(index_region)

;-----------------------------
    wallClockElapseTime(wcStrt, "Processing", 0)
    wcStrtGraphics = systemfunc(date_cmd)
;---Graphics------------------
    wks_name = "FigureS7"
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
    res@gsnLeftStringOrthogonalPosF = 0.004
    res@gsnLeftStringFontHeightF = 0.019
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
    ;hgtres
    shres = res
    shres@gsnCenterString = ""
    shres@cnFillDrawOrder = "PostDraw"
    shres@cnFillOn  = False
    shres@cnLinesOn = True
    shres@cnInfoLabelOn   = False
    shres@cnLineLabelsOn = False
    shres@cnLevelSelectionMode = "ExplicitLevels"
    shres@cnLevels = (/588/)*10
    ;sh_colors = (/(/0,0,0,0/),(/178/255.,34/255.,34/255.,0.7/)/)
    shres@sfXArray = lonCell
    shres@sfYArray = latCell
    shres@cnLineThicknessF = 5*N_res
    shres@cnLineDashPattern = 0


    contour = new(2,graphic)
    shade   = new(2,graphic);figure a and b
    contour_hgt = new(2,graphic)

    cnres@gsnLeftString = "~F26~a"
    cnres@gsnCenterString = "~F26~2-m temperature trend"
    contour(0) = gsn_csm_contour_map(wks, t2m, cnres)
    shade(0) = gsn_csm_contour(wks, t2m_prob, sdres)
    overlay(contour(0), shade(0))
    cnres@gsnLeftString = "~F26~b"
    cnres@gsnCenterString = "~F26~500-hPa temperature trend"
    contour(1) = gsn_csm_contour_map(wks, t_500hPa, cnres)
    shade(1) = gsn_csm_contour(wks, t_500hPa_prob, sdres)
    overlay(contour(1), shade(1))
    shres@cnLineColor = "Violetred"
    contour_hgt(0) = gsn_csm_contour(wks,height_ctl,shres)
    overlay(contour(1),contour_hgt(0))
    shres@cnLineColor = "dodgerblue"
    contour_hgt(1) = gsn_csm_contour(wks,height_rm_t_mp,shres)
    overlay(contour(1),contour_hgt(1))


    box_lat = (/35,35,50,50,35/)
    box_lon = (/85,115,115,85,85/)
    plres   = True
    plres@gsLineDashPattern = 0
    plres@gsLineColor = "dimgray"
    plres@gsLineThicknessF = 5*N_res
    box0 = gsn_add_polyline(wks, shade(0), box_lon, box_lat, plres)
    box1 = gsn_add_polyline(wks, shade(1), box_lon, box_lat, plres)

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
    lbres1@vpYF = 0.34
    lbres1@vpWidthF = 0.6
    lbres1@vpHeightF= 0.04

    lbres1@lbFillColors  := colors
    lbres1@lbTitleString = "~F25~Temperature trend (K/decade)";optional
    lbres1@lbLabelStride = 4
    lbid_trend = gsn_create_labelbar(wks,dimsizes(colors),cnlevels,lbres1)
    draw(lbid_trend)

    resP = True
    resP@gsnPanelLabelBar = False
    resP@gsnMaximize = True
    resP@gsnPanelRowSpec = True
    resP@gsnPanelCenter = True
    ;resP@gsnPanelDebug = True
    resP@gsnPanelYWhiteSpacePercent = 10
    resP@gsnPanelBottom = 0.06
    ;resP@gsnPanelTop = 0.99
    gsn_panel(wks,contour,(/2/),resP)
    ;drawNDCGrid(wks)

;-----------------------------
    wallClockElapseTime(wcStrtGraphics, "Graphics", 0)
    wallClockElapseTime(wcStrt, "Processing and Graphics", 0)
    end
