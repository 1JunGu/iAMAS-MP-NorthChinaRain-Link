begin
    print_clock("start")
;---Processing------------------
    nyear_anomaly = asciiread("./anomaly_nyear.txt",-1,"double")
    nyear_rx3day = asciiread("./rx3day_anomaly.txt",-1,"double")
    year_list = ispan(1961,2023,1)
;---Graphics------------------

    N_res = 2
    wks_type = "png"
    wks_type@wkWidth  = 1024*N_res;
    wks_type@wkHeight = 1024*N_res
    ;wks_type@wkPDFResolution = 6000
    wks = gsn_open_wks(wks_type, "./Figure1c")

    res = True
    res@gsnDraw = False
    res@gsnFrame= False
    res@gsnMaximize  = False
    res@gsnScale = True
    res@gsnLeftString            = "~F26~c"
    res@gsnLeftStringFontHeightF = 0.03
    res@gsnCenterStringFontHeightF = 0.024
    res@gsnCenterString = "~F26~Temporal precipitation anomaly"
    res@gsnRightString            = ""
    res@gsnLeftStringOrthogonalPosF = 0.005
    res@gsnCenterStringOrthogonalPosF = 0.005

    res@vpHeightF = 0.8
    res@vpWidthF  = 0.8
    res@vpXF = 0.1
    res@vpYF = 0.95


    ;mpres@pmTickMarkDisplayMode = "Always"
    res@tmXTOn = False
    res@tmBorderThicknessF = 4.5*N_res
    res@tmYLMajorThicknessF = 3.5*N_res
    res@tmYLMinorThicknessF = 3.5*N_res
    res@tmYLMajorOutwardLengthF = 0.01
    res@tmYLMajorLengthF    = 0.01
    res@tmYLMinorOutwardLengthF = 0.004
    res@tmYLMinorLengthF    = 0.004
    res@tmXBMajorThicknessF = 3.5*N_res
    res@tmXBMinorThicknessF = 3.5*N_res
    res@tmXBMajorOutwardLengthF = 0.01
    res@tmXBMajorLengthF    = 0.01
    res@tmXBMinorOutwardLengthF = 0.004
    res@tmXBMinorLengthF    = 0.004
    res@tmXBLabelFont = 25
    res@tmYLLabelFont = 25
    res@tmYLLabelDeltaF = -0.4

    res@tmXBMinorOn = True
    res@tmYLMinorOn = True
    ;res@tmXBLabelDeltaF = -0.5
    ;res@tmYLLabelDeltaF = -0.5
    res@tmXBLabelFontHeightF = 0.018
    res@tmYLLabelFontHeightF = 0.016

    res@trXMinF = 1960
    res@trXMaxF = 2024
    res@tmXBMode = "Explicit"
    res@tmXBValues = ispan(1963,2023,10)
    res@tmXBLabels = res@tmXBValues
    res@tmXBMinorValues = ispan(1961,2023,1)


    res@trYMinF = -32
    res@trYMaxF = 136
    res@tmYLMode = "Explicit"
    res@tmYLValues = ispan(-20,120,20)
    res@tmYLLabels = res@tmYLValues
    res@tmYLMinorValues = ispan(-30,136,5)
    res@tiYAxisFont = 25
    res@tiYAxisFontHeightF = 0.022

    res@tmYUseLeft = True
    res@tmYROn = True
    res@tmYRLabelsOn = True
    res@tmYRMode = "Explicit"
    res@tmYRValues = ispan(-20,80,20)
    res@tmYRLabels = res@tmYRValues
    res@tmYRLabelFont = 25
    res@tmYRMinorValues = ispan(-20,90,5)

    ;barcharts
    bres = res
    bres@tiYAxisSide = "Left"
    bres@tiYAxisString = "Precipitation anomaly (mm)"
    ;cmap = read_colormap_file("MPL_PRGn")
    cmap = read_colormap_file("MPL_BrBG")
    above_c = cmap(117,:)
    below_c = cmap(20,:)
    bres@gsnYRefLine = 0.
    bres@gsnXYBarChart = True
    bres@gsnAboveYRefLineBarColors = above_c
    bres@gsnBelowYRefLineBarColors = below_c
    bres@gsnYRefLineThicknessF = 6.5*N_res
    ;res@gsnXYBarChartOutlineOnly = True
    bres@gsnXYBarChartBarWidth = 0.66
    bres@xyLineColors = (/above_c,below_c/)

    ;xyline
    xyres = res
    ;RX3_linecolor = (/69.,75.,135./)/256.
    ;RX3_linecolor = (/60.,84.,135./)/256.
    RX3_linecolor = "Black"
    xyres@xyLineColor = RX3_linecolor
    xyres@xyLineThicknessF = 6*N_res

    xyres@tiYAxisString = "RX3DAY anomaly (mm)"
    xyres@tiYAxisSide = "Right"
    ;xyres@tiYAxisAngleF = 270

    xyres@gsnYRefLine           = nyear_rx3day(62)               ; Draw horiz line at y=20
    xyres@gsnYRefLineColor      = RX3_linecolor
    xyres@gsnYRefLineThicknessF = 6.5*N_res
    xyres@gsnYRefLineDashPattern = 1

    ;-------Plot---------
    barcharts = gsn_csm_xy(wks,year_list,nyear_anomaly,bres)
    xyline = gsn_csm_xy(wks,year_list,nyear_rx3day,xyres)
    gres = True
    gres@YPosPercent = 88.               ; expressed as %, 0->100, sets position of bottom border of legend
                                        ;  when gres@Position="Bottom" (Default = 95.)
    gres@XPosPercent = 15.               ; expressed as %, 0->100, sets position of left border of legend
                                        ;  (Default = 5.)
    gres@Position = "Top"            ; YPosPercent setting reflects the "Top" or "Bottom" of legend
                                        ;  (Default="Top")
    gres@ItemSpacePercent = 2.          ; expressed as %, 0->100, space between legend items (Default = 2.5)
    gres@LineLabelWhiteSpacePercent = 2 ; expressed as %, 0->100, space between line and label (Default = 3.)

    lineres = True
    lineres@lgLineColors = RX3_linecolor; line colors
    ;lineres@lgLineOpacity = (/0.3/)              ; line opacities
    lineres@lgLineThicknesses = (/6.5/)*N_res         ; line thicknesses
    lineres@lgDashIndexes = (/0/)                   ; line types
    lineres@LineLengthPercent = 6                        ; expressed as %, 0->100, length of line

    textres = True
    textres@lgLabels ="~F25~" +  (/"RX3DAY"/) ; labels (req)
    textres@lgLabelFontHeights = (/0.018/)                           ; label font heights
    textres@lgLabelColor = RX3_linecolor; label font colors
    ;textres@lgLabelOpacity = (/0.8/)                                     ; 0->1, label opacities
    simple_legend_ndc(wks,gres,lineres,textres)

    plres = True
    plres@gsLineColor = above_c
    plres@gsLineThicknessF = 5*N_res
    plres@gsLineDashPattern = 1
    yref = (/nyear_anomaly(62), nyear_anomaly(62)/)
    xref = (/1960,2024/)
    ref_line = gsn_add_polyline(wks, barcharts, xref, yref, plres)
    ;overlay(barcharts, xyline)
    anno_id  = gsn_add_annotation(barcharts, xyline, False) ; Important to add another Y axis string

    draw(barcharts)
    frame(wks)
    print_clock("finish")
;-----------------------------
end
