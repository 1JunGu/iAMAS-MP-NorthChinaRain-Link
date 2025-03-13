procedure add_lc_labels(wks,map,minlat,maxlat,minlon,maxlon,\
                        lat_spacing[1]:integer,lon_spacing[1]:integer)
local lat_values, nlat, lat1_ndc, lat2_ndc, lon1_ndc, lon2_ndc,slope,txres, \
lon_values,  RAD_TO_DEG, dum_lft, dum_rgt, dum_bot
begin
  RAD_TO_DEG = get_r2d("double")

;---Pick some "nice" values for the latitude labels.
  minlat_ceil  = ceil(minlat/5.)*5
  maxlat_floor = floor(maxlat/5.)*5
  lat_values = ispan(toint(minlat_ceil),toint(maxlat_floor),lat_spacing) * 1.
  nlat       = dimsizes(lat_values)
;
; We need to get the slope of the left and right min/max longitude lines.
; Use NDC coordinates to do this.
;
  lat1_ndc = new(1,float)
  lon1_ndc = new(1,float)
  lat2_ndc = new(1,float)
  lon2_ndc = new(1,float)
  datatondc(map,minlon,lat_values(0),lon1_ndc,lat1_ndc)
  datatondc(map,minlon,lat_values(nlat-1),lon2_ndc,lat2_ndc)
  if(lon2_ndc.eq.lon1_ndc) then
      print("add_lc_labels: error: not enough valid latitude values to generate labels")
      print("    You may need to decrease the lat_spacing")
      exit
  end if
  slope_lft = (lat2_ndc-lat1_ndc)/(lon2_ndc-lon1_ndc)

  datatondc(map,maxlon,lat_values(0),lon1_ndc,lat1_ndc)
  datatondc(map,maxlon,lat_values(nlat-1),lon2_ndc,lat2_ndc)
  if(lat2_ndc.eq.lat1_ndc) then
      print("add_lc_labels: error: not enough valid longitude values to generate labels")
      print("    You may need to decrease the lon_spacing")
      exit
  end if
  slope_rgt = (lat2_ndc-lat1_ndc)/(lon2_ndc-lon1_ndc)

;---Set some text resources
  txres               = True
  txres@txFont = 25
  txres@txFontQuality = "High"
  txres@txFontHeightF = 0.03
  txres@txPosXF       = 0.1
;
; Loop through lat values, and attach labels to the left and
; right edges of the masked LC plot.  The labels will be 
; rotated to fit the line better.
;
  dum_lft = new(nlat,graphic)    ; Dummy array to hold attached strings.
  dum_rgt = new(nlat,graphic)    ; Dummy array to hold attached strings.
  do n=0,nlat-1
; Add extra white space to labels.
    lat_label_rgt = "          "  + lat_values(n) + "~S~o~N~"

;---Check if North, South, or Zero
    if(lat_values(n).lt.0) then
      lat_label_lft = lat_values(n) + "~S~o~N~S          "
      lat_label_rgt = lat_label_rgt + "S"
    end if
    if(lat_values(n).gt.0) then
      lat_label_lft = lat_values(n) + "~S~o~N~N          "
      lat_label_rgt = lat_label_rgt + "N"
    end if
    if(lat_values(n).eq.0) then
      lat_label_lft = lat_values(n) + "~S~o~N~           "
    end if

;---Left label
    txres@txAngleF = RAD_TO_DEG * atan(slope_lft) - 90
    dum_lft(n) = gsn_add_text(wks,map,lat_label_lft,minlon,lat_values(n),txres)

;---Right label
    ;txres@txAngleF = RAD_TO_DEG * atan(slope_rgt) + 90
    ;dum_rgt(n) = gsn_add_text(wks,map,lat_label_rgt,maxlon,lat_values(n),txres)
  end do

;----------------------------------------------------------------------
; Now do longitude labels. These are harder because we're not
; adding them to a straight line.
;
; Loop through lon values, and attach labels to the bottom edge of the
; masked LC plot.
;
  delete(txres@txPosXF)
  txres@txPosYF = -5.0

;---Pick some "nice" values for the longitude labels.
  lon_values = ispan(toint(minlon)+5,toint(maxlon)-5,lon_spacing) * 1.
  nlon       = dimsizes(lon_values)

  dum_bot = new(nlon,graphic)    ; Dummy array to hold attached strings.

  do n=0,nlon-1
;
; For each longitude label, we need to figure out how much to rotate
; it, so get the approximate slope at that point.
;
    datatondc(map,lon_values(n)-0.25,minlat,lon1_ndc,lat1_ndc)
    datatondc(map,lon_values(n)+0.25,minlat,lon2_ndc,lat2_ndc)
    slope_bot = (lat1_ndc-lat2_ndc)/(lon1_ndc-lon2_ndc)
    txres@txAngleF  = atan(slope_bot) * RAD_TO_DEG
;
; Create longitude label. Add extra carriage returns to
; move label away from plot.
;
;---Check if East, West, or Zero
    lon_label_bot = "  ~C~  ~C~" + abs(lon_values(n)) + "~S~o~N~"
    if(lon_values(n).lt.0) then
      lon_label_bot = lon_label_bot + "W"
    end if
    if(lon_values(n).gt.0) then
      lon_label_bot = lon_label_bot + "E"
    end if

;---Attach to map.
    dum_bot(n) = gsn_add_text(wks,map,lon_label_bot,lon_values(n),minlat,txres)
  end do
end
begin
    print_clock("start")
    case_list = (/"CTL","RM_T_MP"/)
    date_list = (/"2023-07-29","2023-07-30","2023-07-31"/)
    data_path = "../../" + case_list + "/v4km/sep_vars/ensemble_0728_12/daily_avg/"
    data_out_path = "../../" + case_list + "/v4km/sep_vars_out/ensemble_0728_12/daily_avg/"
    rain_ctl_fi = addfiles(data_path(0) + date_list +  "/rain_hr.nc","r")
    ListSetType(rain_ctl_fi, "join")
    rain_ctl = rain_ctl_fi[:]->rain_hr * 24 ;mm/day

    rain_ctl_fi = addfiles(data_out_path(0) + date_list +  "/isobaric/height_isobaric.nc","r")
    ;rain_ctl_fi = addfiles(data_path(0) + date_list +  "/height_500hPa.nc","r")
    ListSetType(rain_ctl_fi, "join")
    height_ctl = rain_ctl_fi[:]->height(:,:,19)
    Re = get_sphere_radius()
    height_ctl = height_ctl*Re/(height_ctl+Re) ;convert to geopotential height

    uReconstructZonal_ctl_fi = addfiles(data_out_path(0) + date_list + "/isobaric/ERA5/uReconstructZonal.nc","r")
    ListSetType(uReconstructZonal_ctl_fi, "join")
    nLevels = uReconstructZonal_ctl_fi[0]->nLevels
    ind_500hPa = ind(nLevels.eq.50000)
    uzonal_ctl = uReconstructZonal_ctl_fi[:]->uReconstructZonal(:,ind_500hPa,:,:)

    uReconstructMeridional_ctl_fi = addfiles(data_out_path(0) + date_list + "/isobaric/ERA5/uReconstructMeridional.nc","r")
    ListSetType(uReconstructMeridional_ctl_fi, "join")
    umeridional_ctl = uReconstructMeridional_ctl_fi[:]->uReconstructMeridional(:,ind_500hPa,:,:)

    q_ctl_fi = addfiles(data_out_path(0) + date_list + "/isobaric/ERA5/qv.nc","r")
    ListSetType(q_ctl_fi, "join")
    q_ctl = q_ctl_fi[:]->qv(:,ind_500hPa,:,:)

    qu_ctl = uzonal_ctl*q_ctl*1e3
    qv_ctl = umeridional_ctl*q_ctl*1e3
    copy_VarCoords(q_ctl, qu_ctl)
    copy_VarCoords(q_ctl, qv_ctl)

    rain_rm_t_mp_fi = addfiles(data_path(1) + date_list + "/rain_hr.nc","r")
    ListSetType(rain_rm_t_mp_fi, "join")
    rain_rm_t_mp = rain_rm_t_mp_fi[:]->rain_hr * 24 ;mm/day

    rain_rm_t_mp_fi = addfiles(data_out_path(1) + date_list +  "/isobaric/height_isobaric.nc","r")
    ;rain_rm_t_mp_fi = addfiles(data_path(1) + date_list +  "/height_500hPa.nc","r")
    ListSetType(rain_rm_t_mp_fi, "join")
    height_rm_t_mp = rain_rm_t_mp_fi[:]->height(:,:,19)
    printVarSummary(height_rm_t_mp)
    height_rm_t_mp = height_rm_t_mp*Re/(height_rm_t_mp+Re) ;convert to geopotential height

    uReconstructZonal_rm_t_mp_fi = addfiles(data_out_path(1) + date_list + "/isobaric/ERA5/uReconstructZonal.nc","r")
    ListSetType(uReconstructZonal_rm_t_mp_fi, "join")
    uzonal_rm_t_mp = uReconstructZonal_rm_t_mp_fi[:]->uReconstructZonal(:,ind_500hPa,:,:)

    uReconstructMeridional_rm_t_mp_fi = addfiles(data_out_path(1) + date_list + "/isobaric/ERA5/uReconstructMeridional.nc","r")
    ListSetType(uReconstructMeridional_rm_t_mp_fi, "join")
    umeridional_rm_t_mp = uReconstructMeridional_rm_t_mp_fi[:]->uReconstructMeridional(:,ind_500hPa,:,:)

    q_rm_t_mp_fi = addfiles(data_out_path(1) + date_list + "/isobaric/ERA5/qv.nc","r")
    ListSetType(q_rm_t_mp_fi, "join")
    q_rm_t_mp = q_rm_t_mp_fi[:]->qv(:,ind_500hPa,:,:)

    qu_rm_t_mp = uzonal_rm_t_mp*q_rm_t_mp*1e3
    qv_rm_t_mp = umeridional_rm_t_mp*q_rm_t_mp*1e3
    copy_VarCoords(q_rm_t_mp, qu_rm_t_mp)
    copy_VarCoords(q_rm_t_mp, qv_rm_t_mp)

    static_fi = addfile("/home/export/online1/mdt00/shisuan/swustc/jungu/MPAS/meshes/rotated_4-60km_28N117E_785410/init_static.nc","r")
    R2D = get_r2d("double")
    latCell = static_fi->latCell*R2D
    lonCell = static_fi->lonCell*R2D

    minlat = 28. ;convert to floats for "add_lc_labels"
    maxlat = 45.
    minlon = 105.
    maxlon = 130.

    N_res = 4
    wks_type = "png"
    wks_type@wkWidth  = 1024*N_res;
    wks_type@wkHeight = 1024*N_res
    wks = gsn_open_wks(wks_type, "./FigureR3_588.png")

    ;rain_cnlevels = (/0.1, 1, 5, 10, 25., 50,75, 100.,150,200,300,400,500,600/);16 colors
    rain_cnlevels = (/0.1, 0.5, 1, 5, 10., 25, 50, 75.,100,150,200,250,300,350/);16 colors
    rain_cmap = read_colormap_file("precip2_17lev")
    rain_colors = new((/15,4/),float)
    rain_colors(0,:) = rain_cmap(0,:)
    rain_colors(1:14,:) = rain_cmap(3:16,:)

    rain_diff_cmap =  read_colormap_file("MPL_BrBG")
    rain_diff_colors = new((/52,4/),"float")
    rain_diff_colors = rain_diff_cmap(12:114:2,:)
    rain_diff_levels = fspan(-100,100,51); rain difference

    res = True
    res@gsnDraw = False
    res@gsnFrame= False
    res@gsnAddCyclic = False
    res@gsnMaximize  = True
    res@gsnStringFont = 26
    res@gsnRightString  = ""
    res@gsnLeftStringFontHeightF = 0.03
    res@gsnCenterStringFontHeightF = 0.024
    res@gsnLeftStringOrthogonalPosF = 0.04
    res@gsnCenterStringOrthogonalPosF = 0.035
    ;res@gsnRightStringOrthogonalPosF = 0.02

    ;lres@vpHeightF = 0.8
    ;lres@vpWidthF  = 0.8
    ;lres@vpXF = 0.1
    ;lres@vpYF = 0.95

    mpres = res
    mpres@mpProjection = "LambertConformal"
    mpres@mpLambertParallel1F = 35
    mpres@mpLambertParallel2F = 45
    mpres@mpLambertMeridianF = 117.5

    mpres@mpLimitMode   	= "LatLon"
    mpres@mpMinLatF = minlat
    mpres@mpMaxLatF = maxlat
    mpres@mpMinLonF = minlon
    mpres@mpMaxLonF = maxlon
    mpres@gsnMaskLambertConformal = True
    mpres@gsnMaskLambertConformalOutlineOn = False

    mpres@mpDataSetName            = "$HOME/jungu/data/database/Earth..4"
    mpres@mpDataBaseVersion        = "MediumRes"
    ;mpres@mpAreaMaskingOn = True
    mpres@mpOutlineSpecifiers        = (/"China","China:Provinces"/)
    mpres@mpLandFillColor            = "white"
    mpres@mpInlandWaterFillColor     = "white"
    mpres@mpOceanFillColor           = "white"
    mpres@mpFillBoundarySets         = "NoBoundaries"
    mpres@mpOutlineBoundarySets      = "Geophysical"
    mpres@mpNationalLineColor        = "black"
    mpres@mpProvincialLineColor      = "black"
    mpres@mpGeophysicalLineColor     = "black"
    mpres@mpNationalLineThicknessF   = 4*N_res
    mpres@mpProvincialLineThicknessF = 2*N_res
    mpres@mpGeophysicalLineThicknessF = 2*N_res

    mpres@mpGridAndLimbOn       = False
    mpres@mpGridSpacingF        = 5.0
    mpres@mpGridLineDashPattern = 2
    mpres@mpGridLineThicknessF  = 1.5*N_res

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

    ;mpres@tmXBMode = "Explicit"
    ;mpres@tmXBValues = fspan(105,125,5)
    ;mpres@tmXBLabels = mpres@tmXBValues + "~S~o~N~E"
    ;mpres@tmXBMinorValues = ispan(105,129,1)

    ;mpres@tmYLMode = "Explicit"
    ;mpres@tmYLValues = fspan(30,45,4)
    ;mpres@tmYLLabels = mpres@tmYLValues + "~S~o~N~N"
    ;mpres@tmYLMinorValues = ispan(26,45,1)

    ;-------Plot---------
    plot = new(9,graphic)
    vector = new(9,graphic)
    Leftstring_list =  (/"a ", "b ", "c ", "d ", "e ", "f ", "g ", "h ", "i "/)

    shres = res
    shres@gsnCenterString = ""
    shres@gsnLeftString = ""
    shres@gsnRightString = ""
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
    shres@cnLineThicknessF = 6*N_res
    shres@cnLineDashPattern = 0

    sdres = mpres
    sdres@cnFillDrawOrder = "Draw"
    sdres@cnFillOn = True
    sdres@cnLinesOn = False
    sdres@cnInfoLabelOn   = False
    sdres@cnLineLabelsOn  = False

    sdres@cnFillMode = "RasterFill"
    sdres@cnRasterSmoothingOn = True

    sdres@cnLevelSelectionMode = "ExplicitLevels"
    sd_cnlevels = fspan(-5,5,51)
    sd_cmap =  read_colormap_file("MPL_RdBu")
    sd_colors = new((/52,4/),"float")
    sd_colors = sd_cmap(12:114:-2,:)
    sdres@cnLevels        = sd_cnlevels
    sdres@cnFillColors    = sd_colors
    sdres@lbLabelBarOn    = False

    vcres                       = res
    vcres@vcGlyphStyle          = "LineArrow"
    ;vcres@vcGlyphStyle          = "CurlyVector"
    vcres@vcRefLengthF          = 0.02
    vcres@vcLineArrowColor      = "Black"
    vcres@vcMinDistanceF        = 0.023          ; set to small value to thin the vectors.
    vcres@vcLineArrowThicknessF = 4.            ; make the vectors thicker.
    vcres@vcVectorDrawOrder     = "PostDraw"

    vcres@vcRefAnnoOn               = True
    vcres@vcRefMagnitudeF           = 50.0
    vcres@vcRefAnnoString1          = "~F25~50 g/kg m/s"
    vcres@vcRefLengthF              = 0.03   ; define length of vec ref
    vcres@vcRefAnnoFontHeightF      = 0.02
    vcres@vcRefAnnoFontThicknessF   = 1.
    vcres@vcRefAnnoSide             = "Right"
    ;vcres@vcRefAnnoJust             = "TopLeft"
    vcres@vcRefAnnoString2On        = False
    vcres@vcRefAnnoPerimOn          = False
    vcres@vcRefAnnoOrthogonalPosF   = 0
    vcres@vcRefAnnoParallelPosF     = 0.99
    vcres@vcRefAnnoBackgroundColor  = "white"

    ;sdres@gsnLeftString = Leftstring_list(0) + "500-hPa moisture flux and vertical speed"
    ;plot(0) = gsn_csm_contour_map(wks,w_s,sdres)
    ;contour = gsn_csm_contour(wks,h_s({minlat:maxlat},{minlon:maxlon}),shres)
    ;vector  = gsn_csm_vector(wks,qu({minlat+0.25:maxlat-0.25},{minlon+0.25:maxlon-0.25}),qv({minlat+0.25:maxlat-0.25},{minlon+0.25:maxlon-0.25}),vcres)
    ;overlay(plot(0),vector)
    ;overlay(plot(0),contour)

    cnres = mpres
    cnres@cnFillDrawOrder = "Draw"
    cnres@cnFillOn = True
    cnres@cnLinesOn = False
    cnres@cnInfoLabelOn   = False
    cnres@cnLineLabelsOn  = False

    cnres@cnFillMode = "RasterFill"

    cnres@cnLevelSelectionMode = "ExplicitLevels"
    cnres@cnLevels        = rain_cnlevels
    cnres@cnFillColors    = rain_colors
    cnres@lbLabelBarOn    = False
    cnres@trGridType = "TriangularMesh"
    cnres@sfXArray = lonCell
    cnres@sfYArray = latCell
    ;cnres@cnRasterSmoothingOn = True

    cnres@gsnLeftString = Leftstring_list(0)
    cnres@gsnCenterString = "July 29th"
    plot(0) = gsn_csm_contour_map(wks,rain_ctl(0,:),cnres)
    vcres@vcRefAnnoOn               = False
    vector(0)  = gsn_csm_vector(wks,qu_ctl(0,{minlat+0.25:maxlat-0.25},{minlon+0.25:maxlon-0.25}),qv_ctl(0,{minlat+0.25:maxlat-0.25},{minlon+0.25:maxlon-0.25}),vcres)
    overlay(plot(0), vector(0))
    contour_hgt = new(9,graphic)
    shres@cnLineColor = "Violetred"
    contour_hgt(0) = gsn_csm_contour(wks,height_ctl(0,:),shres)
    overlay(plot(0),contour_hgt(0))

    txres = True
    txres@txFont = 26
    txres@txFontHeightF = 0.012
    txres@txDirection="Across"
    txres@txAngleF = 90
    gsn_text_ndc(wks,"CTL",0.01,0.85,txres)

    cnres@gsnLeftString = Leftstring_list(1)
    cnres@gsnCenterString = "July 30th"
    plot(1) = gsn_csm_contour_map(wks,rain_ctl(1,:),cnres)
    vcres@vcRefAnnoOn               = False
    vector(1)  = gsn_csm_vector(wks,qu_ctl(1,{minlat+0.25:maxlat-0.25},{minlon+0.25:maxlon-0.25}),qv_ctl(1,{minlat+0.25:maxlat-0.25},{minlon+0.25:maxlon-0.25}),vcres)
    overlay(plot(1), vector(1))
    ;shres@cnLineColor = "dodgerblue"
    contour_hgt(1) = gsn_csm_contour(wks,height_ctl(1,:),shres)
    overlay(plot(1),contour_hgt(1))

    cnres@gsnLeftString = Leftstring_list(2)
    cnres@gsnCenterString = "July 31st"
    plot(2) = gsn_csm_contour_map(wks,rain_ctl(2,:),cnres)
    vcres@vcRefAnnoOn               = True
    vector(2)  = gsn_csm_vector(wks,qu_ctl(2,{minlat+0.25:maxlat-0.25},{minlon+0.25:maxlon-0.25}),qv_ctl(2,{minlat+0.25:maxlat-0.25},{minlon+0.25:maxlon-0.25}),vcres)
    overlay(plot(2), vector(2))
    ;shres@cnLineColor = "dodgerblue"
    contour_hgt(2) = gsn_csm_contour(wks,height_ctl(2,:),shres)
    overlay(plot(2),contour_hgt(2))

    cnres@gsnLeftString = Leftstring_list(3)
    cnres@gsnCenterString = ""
    plot(3) = gsn_csm_contour_map(wks,rain_rm_t_mp(0,:),cnres)
    vcres@vcRefAnnoOn               = False
    vector(3)  = gsn_csm_vector(wks,qu_rm_t_mp(0,{minlat+0.25:maxlat-0.25},{minlon+0.25:maxlon-0.25}),qv_rm_t_mp(0,{minlat+0.25:maxlat-0.25},{minlon+0.25:maxlon-0.25}),vcres)
    overlay(plot(3), vector(3))
    gsn_text_ndc(wks,"RM_T_MP",0.01,0.55,txres)

    shres@cnLineColor = "dodgerblue"
    contour_hgt(3) = gsn_csm_contour(wks,height_rm_t_mp(0,:),shres)
    overlay(plot(3),contour_hgt(3))

    cnres@gsnLeftString = Leftstring_list(4)
    cnres@gsnCenterString = ""
    plot(4) = gsn_csm_contour_map(wks,rain_rm_t_mp(1,:),cnres)
    vector(4)  = gsn_csm_vector(wks,qu_rm_t_mp(1,{minlat+0.25:maxlat-0.25},{minlon+0.25:maxlon-0.25}),qv_rm_t_mp(1,{minlat+0.25:maxlat-0.25},{minlon+0.25:maxlon-0.25}),vcres)
    overlay(plot(4), vector(4))
    contour_hgt(4) = gsn_csm_contour(wks,height_rm_t_mp(1,:),shres)
    overlay(plot(4),contour_hgt(4))

    cnres@gsnLeftString = Leftstring_list(5)
    cnres@gsnCenterString = ""
    plot(5) = gsn_csm_contour_map(wks,rain_rm_t_mp(2,:),cnres)
    vector(5)  = gsn_csm_vector(wks,qu_rm_t_mp(2,{minlat+0.25:maxlat-0.25},{minlon+0.25:maxlon-0.25}),qv_rm_t_mp(2,{minlat+0.25:maxlat-0.25},{minlon+0.25:maxlon-0.25}),vcres)
    overlay(plot(5), vector(5))
    contour_hgt(5) = gsn_csm_contour(wks,height_rm_t_mp(2,:),shres)
    overlay(plot(5),contour_hgt(5))

    cnres@gsnLeftString = Leftstring_list(6)
    cnres@gsnCenterString = ""
    cnres@cnLevels        := rain_diff_levels
    cnres@cnFillColors    := rain_diff_colors
    plot(6) = gsn_csm_contour_map(wks,rain_ctl(0,:) - rain_rm_t_mp(0,:),cnres)
    qu_diff = qu_ctl(0,{minlat+0.25:maxlat-0.25}, {minlon+0.25:maxlon-0.25}) - qu_rm_t_mp(0, {minlat+0.25:maxlat-0.25},{minlon+0.25:maxlon-0.25})
    copy_VarCoords(qu_ctl(0,{minlat+0.25:maxlat-0.25},{minlon+0.25:maxlon-0.25}),qu_diff)
    qv_diff = qv_ctl(0,{minlat+0.25:maxlat-0.25}, {minlon+0.25:maxlon-0.25}) - qv_rm_t_mp(0, {minlat+0.25:maxlat-0.25},{minlon+0.25:maxlon-0.25})
    copy_VarCoords(qv_ctl(0,{minlat+0.25:maxlat-0.25},{minlon+0.25:maxlon-0.25}),qv_diff)
    vector(6)  = gsn_csm_vector(wks,qu_diff,qv_diff,vcres)
    overlay(plot(6), vector(6))
    gsn_text_ndc(wks,"CTL-minus-RM_T_MP",0.01,0.2,txres)

    cnres@gsnLeftString = Leftstring_list(7)
    cnres@gsnCenterString = ""
    plot(7) = gsn_csm_contour_map(wks,rain_ctl(1,:) - rain_rm_t_mp(1,:),cnres)

    qu_diff = qu_ctl(1,{minlat+0.25:maxlat-0.25}, {minlon+0.25:maxlon-0.25}) - qu_rm_t_mp(1, {minlat+0.25:maxlat-0.25},{minlon+0.25:maxlon-0.25})
    copy_VarCoords(qu_ctl(0,{minlat+0.25:maxlat-0.25},{minlon+0.25:maxlon-0.25}),qu_diff)
    qv_diff = qv_ctl(1,{minlat+0.25:maxlat-0.25}, {minlon+0.25:maxlon-0.25}) - qv_rm_t_mp(1, {minlat+0.25:maxlat-0.25},{minlon+0.25:maxlon-0.25})
    copy_VarCoords(qv_ctl(0,{minlat+0.25:maxlat-0.25},{minlon+0.25:maxlon-0.25}),qv_diff)
    vector(7)  = gsn_csm_vector(wks,qu_diff,qv_diff,vcres)
    overlay(plot(7), vector(7))

    cnres@gsnLeftString = Leftstring_list(8)
    cnres@gsnCenterString = ""
    plot(8) = gsn_csm_contour_map(wks,rain_ctl(2,:) - rain_rm_t_mp(2,:),cnres)

    qu_diff = qu_ctl(2,{minlat+0.25:maxlat-0.25}, {minlon+0.25:maxlon-0.25}) - qu_rm_t_mp(2, {minlat+0.25:maxlat-0.25},{minlon+0.25:maxlon-0.25})
    copy_VarCoords(qu_ctl(0,{minlat+0.25:maxlat-0.25},{minlon+0.25:maxlon-0.25}),qu_diff)
    qv_diff = qv_ctl(2,{minlat+0.25:maxlat-0.25}, {minlon+0.25:maxlon-0.25}) - qv_rm_t_mp(2, {minlat+0.25:maxlat-0.25},{minlon+0.25:maxlon-0.25})
    copy_VarCoords(qv_ctl(0,{minlat+0.25:maxlat-0.25},{minlon+0.25:maxlon-0.25}),qv_diff)
    vector(8)  = gsn_csm_vector(wks,qu_diff,qv_diff,vcres)
    overlay(plot(8), vector(8))

    do icase =0,8
        lat_spacing  = 5
        lon_spacing  = 5
        add_lc_labels(wks,plot(icase),minlat,maxlat,minlon,maxlon,lat_spacing,lon_spacing) ; Important
    end do

;Create individual label for (a)
    lbresa = True
    lbresa@vpXF = 0.05
    lbresa@vpYF = 0.69
    lbresa@vpWidthF = 0.27
    lbresa@vpHeightF= 0.04

    lbresa@lbPerimOn = False
    lbresa@lbBoxLinesOn = False
    lbresa@lbBoxSeparatorLinesOn = False
    lbresa@lbBoxLineThicknessF = 1.2*N_res
    lbresa@lbFillColors  = sd_colors
    lbresa@lbMonoFillPattern = True
    lbresa@lbLabelFontHeightF = 0.010
    lbresa@lbLabelAlignment   = "InteriorEdges"
    ;lbresa@lbLabelPosition = "Left"
    lbresa@lbOrientation = "Horizontal"
    lbresa@lbTitlePosition = "Bottom"
    ;lbresa@lbTitleDirection = "Across"
    ;lbresa@lbTitleAngleF = 270.
    ;lbres@lbTitleJust = "TopCenter"
    lbresa@lbTitleFontHeightF = 0.014
    lbresa@lbTitleOffsetF = 0.2
    lbresa@lbTitleExtentF = 0.25
    lbresa@lbTitleString = "~F25~Vertical speed at 500 hPa (m/s)";optional
    lbresa@lbLabelStride = 5
    nboxes = dimsizes(sd_colors)
    labels = "~F25~"+sd_cnlevels
    lbid_wspd = gsn_create_labelbar(wks,nboxes,labels,lbresa)
    ;draw(lbid_wspd)
;Create common label
    lbres = True
    lbres@vpXF = 0.23
    lbres@vpYF = 0.4
    lbres@vpWidthF = 0.54
    lbres@vpHeightF= 0.04

    lbres@lbPerimOn = False
    lbres@lbBoxLinesOn = False
    lbres@lbBoxSeparatorLinesOn = False
    lbres@lbBoxLineThicknessF = 4.0*N_res
    lbres@lbFillColors  := rain_colors
    lbres@lbMonoFillPattern = True
    lbres@lbLabelFontHeightF = 0.010
    lbres@lbLabelAlignment   = "InteriorEdges"
    lbres@lbOrientation = "Horizontal"
    lbres@lbTitlePosition = "Bottom"
    ;lbres@lbTitleJust = "TopCenter"
    lbres@lbTitleFontHeightF = 0.014
    lbres@lbTitleOffsetF = 0.2
    lbres@lbTitleExtentF = 0.25
    lbres@lbTitleString = "~F25~1-day accumulated precipitation (mm)";optional
    lbres@lbLabelStride = 1
    nboxes := dimsizes(rain_colors)
    labels := "~F25~"+rain_cnlevels
    lbid_rain = gsn_create_labelbar(wks,nboxes,labels,lbres)
    draw(lbid_rain)
;Create common label
    lbres1 = True
    lbres1@vpXF = 0.23
    lbres1@vpYF = 0.04
    lbres1@vpWidthF = 0.54
    lbres1@vpHeightF= 0.04

    lbres1@lbPerimOn = False
    lbres1@lbBoxLinesOn = False
    lbres1@lbBoxSeparatorLinesOn = False
    lbres1@lbBoxLineThicknessF = 4.0*N_res
    lbres1@lbFillColors  := rain_diff_colors
    lbres1@lbMonoFillPattern = True
    lbres1@lbLabelFontHeightF = 0.010
    lbres1@lbLabelAlignment   = "InteriorEdges"
    lbres1@lbOrientation = "Horizontal"
    lbres1@lbTitlePosition = "Bottom"
    ;lbres1@lbTitleJust = "TopCenter"
    lbres1@lbTitleFontHeightF = 0.014
    lbres1@lbTitleOffsetF = 0.2
    lbres1@lbTitleExtentF = 0.25
    lbres1@lbTitleString = "~F25~1-day accumulated precipitation differences (mm)";optional
    lbres1@lbLabelStride = 5
    nboxes := dimsizes(rain_diff_colors)
    labels := "~F25~"+rain_diff_levels
    lbid_rain_diff = gsn_create_labelbar(wks,nboxes,labels,lbres1)
    draw(lbid_rain_diff)

    box_lat = (/35,35,41,41,35/)
    box_lon = (/112.5,117.5,117.5,112.5,112.5/)
    plres   = True
    plres@gsLineDashPattern = 0
    plres@gsLineThicknessF  = 10
    plres@gsLineColor = "Black"
    box0 = gsn_add_polyline(wks, plot(0), box_lon, box_lat, plres)
    box1 = gsn_add_polyline(wks, plot(1), box_lon, box_lat, plres)
    box2 = gsn_add_polyline(wks, plot(2), box_lon, box_lat, plres)
    box3 = gsn_add_polyline(wks, plot(3), box_lon, box_lat, plres)
    box4 = gsn_add_polyline(wks, plot(4), box_lon, box_lat, plres)
    box5 = gsn_add_polyline(wks, plot(5), box_lon, box_lat, plres)
    box6 = gsn_add_polyline(wks, plot(6), box_lon, box_lat, plres)
    box7 = gsn_add_polyline(wks, plot(7), box_lon, box_lat, plres)
    box8 = gsn_add_polyline(wks, plot(8), box_lon, box_lat, plres)

    resP = True
    resP@gsnFrame = False
    resP@gsnPanelLabelBar = False
    resP@gsnMaximize = True
    resP@gsnPanelRowSpec = True
    resP@gsnPanelCenter = True
    resP@gsnPanelXWhiteSpacePercent = 5
    resP@gsnPanelYWhiteSpacePercent = 2
    resP@gsnPanelLeft = 0.03
    resP@gsnPanelRight = 0.95
    resP@gsnPanelBottom = 0.42
    resP@gsnPanelDebug = True
    gsn_panel(wks,plot(0:5),(/3,3/),resP)

    resP1 = True
    resP1@gsnFrame = False
    resP1@gsnPanelLabelBar = False
    resP1@gsnMaximize = True
    resP1@gsnPanelRowSpec = True
    resP1@gsnPanelCenter = True
    resP1@gsnPanelXWhiteSpacePercent = 5
    resP1@gsnPanelYWhiteSpacePercent = 0.25
    resP1@gsnPanelLeft = 0.03
    resP1@gsnPanelRight = 0.95
    resP1@gsnPanelTop = 0.35
    resP1@gsnPanelBottom = 0.07
    resP1@gsnPanelDebug = True
    gsn_panel(wks,plot(6:8),(/3/),resP1)

    ;drawNDCGrid(wks)
    frame(wks)
    print_clock("End")
end
