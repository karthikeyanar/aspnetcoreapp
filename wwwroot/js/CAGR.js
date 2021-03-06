﻿function Company() {
    var self = this;

    this.index = -1;
    this.company_json = null;

    this.startInvesting = function () {
        console.log('self.index=', self.index);
        var symbols = '';
        for (var i = 0; i < self.company_json.length; i++) {
            var c = self.company_json[i];
            if (cString(c.LastTradingDate) == '') {
                c.LastTradingDate = '01/01/2007';
            }
            if (cString(c.InvestingUrl) != '') {
                if (c.InvestingUrl.indexOf('?cid=') > -1) {
                    var arr = c.InvestingUrl.split('?cid=');
                    //console.log(arr);
                    c.InvestingUrl = arr[0] + '-historical-data' + '?cid=' + arr[1];
                } else {
                    c.InvestingUrl = c.InvestingUrl + '-historical-data';
                }
                symbols += c.CompanyID + '|' + c.InvestingUrl + '|' + formatDate(c.LastTradingDate, 'DD/MM/YYYY') + '|' + formatDate(new Date(), 'DD/MM/YYYY') + ',';
            }
        }
        if (symbols != '') {
            symbols = symbols.substring(0, symbols.length - 1);
        }
        console.log(symbols);
        if (symbols != '') {
            console.log('call gccmd', symbols);
            var $gcb_cmd = $("#gcb_cmd");
            $gcb_cmd.attr("cmd", "investing-history");
            $gcb_cmd.attr("symbol", symbols);
            $gcb_cmd.click();
        }
    }

    this.startScreener = function () {
        console.log('self.index=', self.index);
        var symbols = '';
        for (var i = 0; i < self.company_json.length; i++) {
            var c = self.company_json[i];
            c.ScreenerUrl = '/company/' + c.Symbol;
            symbols += c.CompanyID + '|' + c.ScreenerUrl + ',';
        }
        if (symbols != '') {
            symbols = symbols.substring(0, symbols.length - 1);
        }
        if (symbols != '') {
            console.log('call gccmd', symbols);
            var $gcb_cmd = $("#gcb_cmd");
            $gcb_cmd.attr("cmd", "screener-history");
            $gcb_cmd.attr("symbol", symbols);
            $gcb_cmd.click();
        }
    }

    this.add = function (companyId) {
        if (companyId > 0) {
            var $tr = $("#tr" + companyId);
            var arr = [];
            arr.push({ "name": "CompanyID", "value": companyId });
            arr.push({ "name": "PageSize", "value": 1 });
            arr.push({ "name": "PageIndex", "value": 1 });
            arr.push({ "name": "SortName", "value": "CompanyID" });
            arr.push({ "name": "SortOrder", "value": "asc" });
            $.ajax({
                type: 'GET',
                url: apiUrl('/Company/List'),
                cache: false,
                data: arr,
                dataType: 'json',
                success: function (json) {
                    console.log(json);
                    if (json.rows.length > 0) {
                        $("#edit-template").tmpl(json).insertAfter($tr);
                    }
                },
                error: function (data) {
                    console.log('error data=', data);
                }
            });
        } else {
            var $tbl = $("#tblCompany");
            var json = { "rows": [] };
            json.rows.push({ "CompanyID": 0, "CompanyName": "", "Symbol": "", "InvestingUrl": "", "IsArchive": false, "IsBookMark": false });
            $("#edit-template").tmpl(json).prependTo($tbl);
            $(":input[name='CompanyName']", $("#trEdit" + companyId)).focus();
        }
    }

}

var _COMPANY = new Company();

$(function () {
    var $tbl = $("#tblCAGR");
    var $fromDate = $(":input[name='FromDate']");

    //$fromDate.val(getMonthFirstDate(new Date()));
    $fromDate.datepicker({
        autoclose: true,
        format: 'yyyy-mm-dd',
        disableTouchKeyboard: true
    });
    //.on('changeDate', function (selected) {
        //console.log('fromDate=', formatDate(selected.date,'YYYY-MM-DD'));
    //    $fromDate.val(formatDate(selected.date,'YYYY-MM-DD'));
    //    $tbl.flexReload2();
    //});

    var $toDate = $(":input[name='ToDate']");
    $toDate.datepicker({
        autoclose: true,
        format: 'yyyy-mm-dd'
    });
    //.on('changeDate', function (selected) {
        //console.log('toDate=', formatDate(selected.date,'yyyy-mm-dd'));
    //    $toDate.val(formatDate(selected.date,'YYYY-MM-DD'));
     //   $tbl.flexReload2();
    //});

    var dt = getMonthFirstDate(new Date());
    console.log('dt=',dt);
    $fromDate.datepicker('setDate', (new Date(dt.toString())));

    $("#chkIsBookMarkCategory").click(function () {
        $tbl.flexReload2();
    });

    $("#chkIsBookMark").click(function () {
        $tbl.flexReload2();
    });

    $tbl.flexigrid2({
        usepager: true,
        useBoxStyle: false,
        url: apiUrl("/Report/CAGR"),
        rpOptions: [500,1000],
        rp: 1000,
        onSubmit: function (p) {
            p.params = [];
            p.params.push({ 'name': 'IsBookMarkCategory', 'value': $('#chkIsBookMarkCategory')[0].checked });
            p.params.push({ 'name': 'IsBookMark', 'value': $('#chkIsBookMark')[0].checked }); 
            p.params.push({ "name": "CategoryIDs", "value": $("#CategoryIDs").val() });
        },
        onSuccess: function (t, g) { },
        onTemplate: function (data) {
            _COMPANY.company_json = data.rows;
            var tbody = $("tbody", $tbl);
            tbody.empty();
            var avg = 0;
            var total = 0;
            for (var i = 0; i < data.rows.length; i++) {
                total += cFloat(data.rows[i].Percentage);
                console.log(data.rows[i].Date + '=' + data.rows[i].Percentage + ',total=' + total);
            }
            //avg = total / data.rows.length;
            $("#lnkAverage").html(formatNumber(total) + '%');
            $("#grid-template").tmpl(data).appendTo(tbody);
        },
        onPaginationElement: function () {
            return $(".manual-pagination");
        },
        onPaginationStatusElement: function () {
            return $("#paging_status");
        },
        onRPSelectElement: function () {
            return $("#rows2");
        },
        resizeWidth: true,
        method: "GET",
        sortname: "",
        sortorder: "",
        autoload: true,
        height: 0,
        applyFixedHeader: true
    });


    console.log('CategoryIDs=',$("#CategoryIDs")[0]);

    $("#CategoryIDs").val("").select2({
        placeholder: "Select Category",
        minimumInputLength: 0,
        maximumSelectionSize: 1000,
        minimumResultsForSearch: 0,
        multiple: true,
        allowClear: false,
        delay: 300,
        width: "300px",
        query: function (query) {
            $.getJSON(apiUrl("/Category/FindCategories?term=" + query.term), function (data) {
                //var data = [];
                //for(var i = 0;i<100;i++){
                //    data.push({"id":"Contact_"+i,"label":"Contact_"+i});
                //}
                var callback = function (data, page) {
                    var s2data = [];
                    $.each(data, function (i, d) {
                        s2data.push({ "id": d.id, "text": d.label, "source": d });
                    });
                    return { results: s2data };
                }
                query.callback(callback(data, query.page));
            });
        }
    }).on("change", function (e) {
        $tbl.flexReload2();
    });

    var $lnkInvestingDownload = $("#lnkInvestingDownload");

    $lnkInvestingDownload.click(function () {
        _COMPANY.startInvesting();
    });

    var $btnRefresh = $("#btnRefresh");

    $btnRefresh.click(function () {
        $tbl.flexReload2();
    });

    var $btnInvestingUpdateCSV = $("#btnInvestingUpdateCSV");
    $btnInvestingUpdateCSV.click(function () {
        var $investing_csv = $("#investing_csv");
        console.log('investing_csv=', $investing_csv.val());
        var url = apiUrl("/Company/UpdateCSV");
        var d = { "csv": $investing_csv.val() };
        $.ajax({
            "url": url,
            "cache": false,
            "type": "POST",
            contentType: 'application/json; charset=utf-8',
            data: JSON.stringify(d)
        }).done(function (json) {
            var html = $("#investing_index").val() + ' of ' + $("#investing_total").val() + " - " + json.CompanyName;
            $("#investing_csv_log").html(html);
            $tbl.flexReload2();
        }).always(function () {
        });
    });

    $("body").on("click", ".isbookmark-change", function () {
        var $this = $(this);
        var $tr = $this.parents("tr:first");
        var companyId = cInt($("#hdnCompanyID", $tr).val());
        var isBookMark = false;
        if ($this.hasClass('fa-star-o')) {
            isBookMark = true;
        } else {
            isBookMark = false;
        }
        $this.removeClass('fa-star').removeClass('fa-star-o');
        if (isBookMark == true) {
            $this.addClass('fa-star');
        } else {
            $this.addClass('fa-star-o');
        }
        var url = apiUrl("/Company/UpdateBookMark");
        var d = { "CompanyID": companyId, "IsBookMark": isBookMark };
        $.ajax({
            "url": url,
            "cache": false,
            "type": "POST",
            contentType: 'application/json; charset=utf-8',
            data: JSON.stringify(d)
        }).done(function (json) {
        }).always(function () {
        });
    });
});