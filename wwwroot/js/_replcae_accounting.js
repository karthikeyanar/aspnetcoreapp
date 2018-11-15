function screenerHistory(tabid, openerId, companyId, startDate, endDate, index, total) {
    window.alert = function () { };
    var $flatDatePickerCanvasHol = $("#flatDatePickerCanvasHol");
    var $picker = $("#picker", $flatDatePickerCanvasHol);
    console.log('$picker=', $picker[0]);
    $picker[0].value = startDate.toString() + ' - ' + endDate.toString();
    console.log('tabid=',tabid,'openerId=',openerId,'companyId=',companyId,'startDate=',startDate,'endDate=',endDate,'index=',index,'total=',total);
    setTimeout(function () {
        var $historicalDataTimeRange = $(".historicalDataTimeRange");
        var $datePickerIconWrap = $("#datePickerIconWrap", $historicalDataTimeRange);
        console.log('datePickerIconWrap=', $datePickerIconWrap[0]);
        $datePickerIconWrap.click();
        setTimeout(function () {
            var $uiDatepickerDiv = $("#ui-datepicker-div");
            var $startDate = $("#startDate", $uiDatepickerDiv);
            var $endDate = $("#endDate", $uiDatepickerDiv);
            var $applyBtn = $("#applyBtn", $uiDatepickerDiv);
            console.log('uiDatepickerDiv=', $uiDatepickerDiv[0]);
            console.log('startDate=', $startDate[0]);
            console.log('endDate=', $endDate[0]);
            console.log('applyBtn=', $applyBtn[0]);
            simulateClick($applyBtn[0]);

            setTimeout(function () {

                var $curr_table = $("#curr_table");
                var $tbody = $("tbody", $curr_table);

                var struct = new tableStructure();
                struct.cols.push("CompanyID");
                struct.cols.push("Date");
                struct.cols.push("Close Price");
                struct.cols.push("Open Price");
                struct.cols.push("High Price");
                struct.cols.push("Low Price");
                struct.cols.push("Volume");
                struct.cols.push("Change");

                $("tr", $tbody).each(function (i) {
                    var row = [];
                    var $tr = $(this);
                    row.push(companyId);
                    row.push($("td:eq(0)", $tr).text()); // date
                    row.push($("td:eq(1)", $tr).text()); // close price
                    row.push($("td:eq(2)", $tr).text()); // open price
                    row.push($("td:eq(3)", $tr).text()); // high price
                    row.push($("td:eq(4)", $tr).text()); // low price
                    row.push($("td:eq(5)", $tr).text()); // volume
                    row.push($("td:eq(6)", $tr).text()); // change

                    struct.rows.push(row);
                });

                var csvContent = convertCSVContent(struct,'\n');

                var csv = convertCSVContent(struct,'|');


                var code = "$('#screener_index').val('" + (index + 1) + "');$('#screener_total').val('" + total + "');$('#screener_csv').val('" + csv + "');$('#btnInvestingUpdateCSV').click();";
                chrome.runtime.sendMessage({ cmd: 'execute_code', 'tabid': openerId, 'code': code });

                var fileName = $.trim($('.float_lang_base_1.relativeAttr').text()) + '-' + companyId + '-' + startDate.toString() + '-' + endDate.toString() + '.csv';
                ////console.log('fileName=', fileName);
                download(csvContent, fileName, 'text/csv;encoding:utf-8');

                setTimeout(function () {
                    chrome.runtime.sendMessage({ cmd: 'screener_close_tab', 'tabid': tabid, 'openerid': openerId });
                }, 1000);

            }, 5000);
        }, 2000);
    }, 2000);
}
