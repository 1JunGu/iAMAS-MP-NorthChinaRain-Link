begin
    minlat = 35
    maxlat = 41
    minlon = 112
    maxlon = 117

	static_finame = "/home/export/online1/mdt00/shisuan/swustc/jungu/MPAS/meshes/rotated_4-60km_28N117E_785410/init_static.nc"
	static_fi = addfile(static_finame,"r")
	r2d = get_r2d("double")
    latCell = static_fi->latCell * r2d
    lonCell = static_fi->lonCell * r2d

    ind_subset = ind(latCell.ge.minlat .and. latCell.le.maxlat .and.\
                     lonCell.ge.minlon .and. lonCell.le.maxlon)

    ;case = (/"CTL","RM_THQ","RM_TH","RM_Q","RM_T","RM_T_NO_MP"/)
    case = (/"CTL","RM_THQ","RM_T","RM_T_NO_MP"/)
    time_list = (/"0728_00","0728_01","0728_02","0728_03","0728_04","0728_05","0728_06","ensemble"/)
    PDF_array = new((/4,40/),double)
    do icase = 0, 3
    do itime =7, 7

        path = "../../" + case(icase) + "/v4km/sep_vars/" + time_list(itime) + "/"
        ;finames = systemfunc("ls " + path + " |grep mpas_diag |grep '07-29\|07-30\|07-31'" ) 
        rainnc_finames = systemfunc("find " + path + " |grep mpas_diag |grep '07-29\|07-30\|07-31' |grep rainnc_hr " ) 
        rainc_finames = systemfunc("find " + path + " |grep mpas_diag |grep '07-29\|07-30\|07-31' |grep rainc_hr" ) 

        fi1 = addfiles(rainnc_finames ,"r")
        fi2 = addfiles(rainc_finames  ,"r")
        ListSetType(fi1,"join")
        ListSetType(fi2,"join") 
        rainnc_hr = fi1[:]->rainnc_hr
        rainc_hr = fi2[:]->rainc_hr
        rain := rainnc_hr + rainc_hr
        rain!0 = "Hours"

        rain_mpas_subset := rain(:,ind_subset)
        ;rain_mpas_subset@_FillValue = -999.9
        ;rain_mpas_subset = where(rain_mpas_subset.lt.5,rain_mpas_subset@_FillValue,rain_mpas_subset)

        opt = True
        opt@bin_min = 0
        opt@bin_max = 40
        mpas_pdf = pdfx(rain_mpas_subset,40,opt)
        ;print(mpas_pdf)
        PDF_array(icase,:) = mpas_pdf
    end do
    end do
    PDF_array = where(PDF_array.eq.0,1e-10,PDF_array);to avoid log(0)

    N_res = 2
    wks_type = "png"
    wks_type@wkWidth  = 1024*N_res;
    wks_type@wkHeight = 1024*N_res
    wks = gsn_open_wks(wks_type, "./FigureS3")

    res = True
    res@vpWidthF = 0.8
    res@vpHeightF = 0.64
    res@vpXF = 0.12
    res@vpYF = 0.9
    res@gsnDraw = False
    res@gsnFrame= False
    ;res@gsnAddCyclic = False
    res@gsnMaximize  = False
    res@gsnLeftStringFontHeightF = 0.02
    res@gsnLeftString  = ""
    res@gsnLeftStringOrthogonalPosF = 0.005
    res@gsnStringFont = 25
    res@tiMainString =  ""

    res@tmXTOn = False
    ;res@tmYROn = False

    res@tmBorderThicknessF = 4.5*N_res
    res@tmYLMajorThicknessF = 3.5*N_res
    res@tmYLMinorThicknessF = 3.5*N_res
    res@tmYLMajorLengthF    = 0.01
    res@tmYLMajorOutwardLengthF = 0.01
    res@tmYLMinorLengthF    = 0.005
    res@tmYLMinorOutwardLengthF = 0.005
    res@tmYRMajorThicknessF = 3.5*N_res
    res@tmYRMinorThicknessF = 3.5*N_res
    res@tmYRMajorLengthF    = 0.01
    res@tmYRMajorOutwardLengthF = 0.01
    res@tmYRMinorLengthF    = 0.005
    res@tmYRMinorOutwardLengthF = 0.005
    res@tmXBMajorThicknessF = 3.5*N_res
    res@tmXBMinorThicknessF = 3.5*N_res
    res@tmXBMajorLengthF    = 0.01
    res@tmXBMajorOutwardLengthF = 0.01
    res@tmXBMinorLengthF    = 0.006
    res@tmXBMinorOutwardLengthF = 0.006

    x_lbvalues = ispan(0,35,1)
    ;x_labels = "~F25~" + sprinti("%02i",(/00,06,12,18,00,06,12,18,00,06,12,18,00/))
    res@tmXBOn   = True
    res@tmXBMode = "Explicit"
    ;res@tmXBLabels = sprinti("%2i", x_labels)
    res@tmXBValues = ispan(0,35,5)
    res@tmXBLabels = res@tmXBValues
    res@tmXBMinorValues = x_lbvalues
    res@tmXBLabelFont = 25
    res@tmYLLabelFont = 25
    res@tmLabelAutoStride = True;nice stride on labels
    res@tmXBLabelFontAspectF = 1.3125
    res@tmXBLabelFontHeightF = 0.016
    res@trXMinF = 0
    res@trXMaxF = 34
    res@tiXAxisString = "~F25~Hourly precipitation (mm/h)"
    res@tiXAxisFontHeightF = 0.018

    ;bres = res
    ;bres@gsnLeftString = "(c) Probability distributions"
    ;bres@gsnLeftStringOrthogonalPosF = -0.001
    ;bres@gsnYRefLine           = 0.;very important for xyline colors
    ;bres@xyLineColor = "Violetred"
    ;bres@xyLineThicknesses = 4.0
    ;bres@gsnXYBarChart = True
    ;bres@gsnXYBarChartBarWidth = 0.6
    ;bres@gsnXYBarChartColors = "dodgerblue"; only useful in fill patterns
    ;bres@gsnXYBarChartPatterns = -1
    ;;bres@gsnXYBarChartFillLineThicknessF = 1
    ;;bres@gsnXYBarChartFillOpacityF = 0.1
    ;;bres@gsnXYBarChartOutlineOnly = True
    ;bres@gsnXYBarChartOutlineThicknessF = 0
    ;bres@tmYROn = False
    ;bres@tmYLLabelsOn = True
    ;bres@tmYLOn   = True
    ;bres@tmYLMode = "Explicit"
    ;bres@tmYLValues = ispan(0,6,1)
    ;bres@tmYLMinorValues = fspan(0,6,31)
    ;bres@tmYLLabels = "~F25~" + bres@tmYLValues
    ;bres@trYMinF = 0
    ;bres@trYMaxF = 5.9

    ;bres@tiYAxisString = "~F25~Hourly precipitation (mm/h)"
    ;bres@tiYAxisSide ="Left"
    ;bres@tiYAxisFontHeightF = 0.018

    ;time_series  = x_lbvalues

    res@tmYLOn = True
    res@tmYRLabelFont = 25
    res@tmYROn = True
    res@tmYRLabelsOn = True
    ;res@tmYLStyle = "Log"
    res@xyYStyle = "Log"
    res@tmYLValues = (/0.1, 1, 10, 100, 1000, 10000,100000/)/1000000
    ;res@tmYLLabels = (/"10~S~-5~N~","10~S~-4~N~","10~S~-3~N~","10~S~-2~N~","10~S~-1~N~","10~S~0~N~","10~S~1~N~"/)
    res@trYMaxF = 80
    res@trYMinF = 1e-4

    res@tiYAxisString = "~F25~Probability (%)"
    res@tiYAxisSide ="Left"
    res@tiYAxisFontHeightF = 0.018

    
    ;colors = (/"Violetred","dodgerblue","goldenrod","forestgreen","turquoise","darkslateblue"/)
    colors = (/"Violetred","dodgerblue","turquoise","darkslateblue"/)
    res@xyDashPatterns  = (/0,0,0,0,0,0/) ; Make curves all solid except offical forecast
    res@xyMarkLineMode = "Lines"
    res@xyMarkers      = (/16,16,16,16,16,16/)
    res@xyMarkerColors = colors
    res@xyLineThicknesses = (/6.5,6.5,6.5,6.5,6.5,6.5/)*N_res
    res@xyLineColors   = colors
    res@xyCurveDrawOrder = "PreDraw"

    ;plot_xy = gsn_csm_xy2(wks,time_series,rain_3day_avg(0:71),rain_3day_array,bres,xyres)

    plot_xy = gsn_csm_xy(wks,mpas_pdf@bin_center,PDF_array,res)

    lnres = True
    lnres@gsLineDashPattern = 11
    lnres@gsLineThicknessF = 4.5*N_res
    lnres@tfPolyDrawOrder = "PostDraw"
    lnres@gsLineColor = "turquoise"
    mkres = True
    mkres@gsMarkerColor = "turquoise"
    mkres@tfPolyDrawOrder = "PreDraw"
    mkres@gsMarkerIndex = 16
    mkres@gsMarkerSizeF = 0.01
    mkres@gsMarkerThicknessF = 4.5*N_res
    anno_11 = gsn_add_polyline(wks, plot_xy, (/24.5,24.5/), (/1e-7,PDF_array(2,24)/), lnres)
    anno_12 = gsn_add_polyline(wks, plot_xy, (/24.5,34/), (/PDF_array(2,24),PDF_array(2,24)/), lnres)
    anno_13 = gsn_add_polymarker(wks, plot_xy, 24.5, PDF_array(2,24), mkres)
    lnres@gsLineColor = "goldenrod"
    mkres@gsMarkerColor = "goldenrod"
    ;anno_21 = gsn_add_polyline(wks, plot_xy, (/22.5,22.5/), (/1e-7,PDF_array(2,22)/), lnres)
    ;anno_22 = gsn_add_polyline(wks, plot_xy, (/22.5,34/), (/PDF_array(2,22),PDF_array(2,22)/), lnres)
    ;anno_23 = gsn_add_polymarker(wks, plot_xy, 22.5, PDF_array(2,22), mkres)

    ;add polygon
    plres =  True
    plres@tfPolyDrawOrder  = "Predraw"
    plres@gsFillOpacityF = 0.2
    plres@gsFillColor = colors(1)
    diff = PDF_array(0,:) - PDF_array(1,:)
    diff = where(diff.le.0, 0, diff)
    index = ind(diff.eq.0)
    print(index)
    print(diff)

    xp =  new(66,double)
    yp =  new(66,double)
    do i =0, 32
        xp(i)    = i + 1.5
        xp(65-i) = i + 1.5
        yp(i)    = PDF_array(1,i+1)
        yp(65-i) = PDF_array(0,i+1)
    end do
    dum = gsn_add_polygon(wks, plot_xy, xp, yp, plres)

    gres = True
    gres@YPosPercent = 55.               ; expressed as %, 0->100, sets position of bottom border of legend
                                        ;  when gres@Position="Bottom" (Default = 95.)
    gres@XPosPercent = 17.               ; expressed as %, 0->100, sets position of left border of legend
                                        ;  (Default = 5.)
    gres@Position = "Top"            ; YPosPercent setting reflects the "Top" or "Bottom" of legend
                                        ;  (Default="Top")
    gres@ItemSpacePercent = 3.          ; expressed as %, 0->100, space between legend items (Default = 2.5)
    gres@LineLabelWhiteSpacePercent = 2 ; expressed as %, 0->100, space between line and label (Default = 3.)

    lineres = True
    lineres@lgLineColors = colors(0:3)
    ;lineres@lgLineOpacity = (/0.3/)              ; line opacities
    lineres@lgLineThicknesses = (/8,8,8,8/)*N_res
    lineres@lgDashIndexes = (/0/)                   ; line types
    lineres@LineLengthPercent = 5                        ; expressed as %, 0->100, length of line

    textres = True
    textres@lgLabels ="~F25~" +  case(0:3)
    textres@lgLabelFontHeights = (/0.015/)                           ; label font heights
    textres@lgLabelColors = colors(0:3)
    ;textres@lgLabelOpacity = (/0.8/)                                     ; 0->1, label opacities
    simple_legend_ndc(wks,gres,lineres,textres)
    draw(plot_xy)
    frame(wks)
end
