
function Company() {
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

    this.startNSE = function () {
        var symbols = '';
        for (var i = 0; i < self.company_json.length; i++) {
            symbols += self.company_json[i].Symbol
                + '|' + formatDate($("#StartDate").val(), 'DD-MM-YYYY')
                + '|' + formatDate($("#EndDate").val(), 'DD-MM-YYYY')
                + '|' + 'EQ' + ',';
        }
        if (symbols != '') {
            symbols = symbols.substring(0, symbols.length - 1);
        }
        $('#gcb_cmd').attr('cmd', 'open_nse');
        $('#gcb_cmd').attr('symbol', symbols);
        $('#gcb_cmd').click();
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

    this.startMoneyControl = function () {
        console.log('self.index=', self.index);
        var symbols = '';
        for (var i = 0; i < self.company_json.length; i++) {
            var c = self.company_json[i];
            if (cString(c.MoneyControlSymbol) != ''
                && cString(c.MoneyControlUrl) != '') {
                var arr = c.MoneyControlUrl.split('/');
                var name = arr[arr.length - 1];
                var url = '/company-facts/' + name + '/shareholding-pattern/' + c.MoneyControlSymbol + '#' + c.MoneyControlSymbol;
                symbols += c.CompanyID + '|' + url + ',';
            }
        }
        if (symbols != '') {
            symbols = symbols.substring(0, symbols.length - 1);
        }
        if (symbols != '') {
            console.log('call gccmd', symbols);
            var $gcb_cmd = $("#gcb_cmd");
            $gcb_cmd.attr("cmd", "moneycontrol-history");
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
    var $tbl = $("#tblCompany");

    var $LastTradingDate = $("#LastTradingDate");

    $LastTradingDate.datepicker({
        autoclose: true
    }).on('changeDate', function (selected) {
        console.log('monthpicker=', selected.date);
        $LastTradingDate.val(formatDate(selected.date));
        $tbl.flexReload2();
    });

    var $StartDate = $("#StartDate");

    $StartDate.datepicker({
        autoclose: true
    }).on('changeDate', function (selected) {
        console.log('monthpicker=', selected.date);
        $StartDate.val(formatDate(selected.date));
    });

    var $EndDate = $("#EndDate");

    $EndDate.datepicker({
        autoclose: true
    }).on('changeDate', function (selected) {
        console.log('monthpicker=', selected.date);
        $EndDate.val(formatDate(selected.date));
    });

    $tbl.flexigrid2({
        usepager: true,
        useBoxStyle: false,
        url: apiUrl("/Company/List"),
        rpOptions: [10, 20, 30, 40, 50, 100, 200, 500, 1000],
        rp: 1000,
        onSubmit: function (p) {
            p.params = [];
            p.params.push({ "name": "CompanyIDs", "value": $("#CompanyIDs").val() });
            p.params.push({ "name": "CategoryIDs", "value": $("#CategoryIDs").val() });
            p.params.push({ "name": "LastTradingDate", "value": $("#LastTradingDate").val() });
            var chk = $("#chkIsBookMarkCategory")[0];
            if (chk.checked) {
                p.params.push({ "name": "IsBookMarkCategory", "value": true })
            }
        },
        onSuccess: function (t, g) { },
        onTemplate: function (data) {
            _COMPANY.company_json = data.rows;
            var tbody = $("tbody", $tbl);
            tbody.empty();
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
        sortname: "CompanyName",
        sortorder: "asc",
        autoload: true,
        height: 0,
        applyFixedHeader: true
    });

    $("#CompanyIDs").val("").select2({
        placeholder: "Select Company",
        minimumInputLength: 0,
        maximumSelectionSize: 1000,
        minimumResultsForSearch: 0,
        multiple: true,
        allowClear: false,
        delay: 300,
        width: "300px",
        query: function (query) {
            $.getJSON(apiUrl("/Company/FindCompanies?term=" + query.term), function (data) {
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

    var $lnkNSEDownload = $("#lnkNSEDownload");

    $lnkNSEDownload.click(function () {
        _COMPANY.startNSE();
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

    $("body").on("click", ".edit-row", function () {
        var $this = $(this);
        var $tr = $this.parents("tr:first");
        var companyId = $("#CompanyID", $tr).val();
        _COMPANY.add(companyId);
    });

    $("body").on("click", "#chkIsBookMarkCategory", function () {
        $tbl.flexReload2();
    });

    $("body").on("click", ".delete-row", function () {
        var $this = $(this);
        var $tr = $this.parents("tr:first");
        var companyId = $("#CompanyID", $tr).val();
        if (confirm('Are you sure?')) {
            $("#tr" + companyId).remove();
            $("#trEdit" + companyId).remove();
            var url = apiUrl("/Company/Delete?id=" + companyId);
            $.ajax({
                "url": url,
                "cache": false,
                "type": "GET"
            }).done(function (json) {
            }).always(function () {
            });
        }
    });

    $("body").on("click", ".delete-price-row", function () {
        var $this = $(this);
        var $tr = $this.parents("tr:first");
        var companyId = $("#CompanyID", $tr).val();
        if (confirm('Are you sure?')) {
            var url = apiUrl("/Company/DeletePriceHistory?id=" + companyId);
            $.ajax({
                "url": url,
                "cache": false,
                "type": "GET"
            }).done(function (json) {
                $tbl.flexReload2();
            }).always(function () {
            });
        }
    });

    $("body").on("click", ".view-row", function () {
        var $this = $(this);
        var $tr = $this.parents("tr:first");
        var companyId = $("#CompanyID", $tr).val();
        var $modal = $("#modalView");
        $modal.modal('show');
        var $modalContent = $(".modal-content", $modal);
        $modalContent.empty();
        var url = apiUrl("/Company/FindCompanyFundamental?id=" + companyId);
        $.ajax({
            "url": url,
            "cache": false,
            "type": "GET"
        }).done(function (json) {
            var d = json[0];
            d.rnd = Math.random() * 1000000 + 100;
            $("#modal-company-template").tmpl(d).appendTo($modalContent);
            google.charts.load('current', {
                'packages': ['bar']
            });
            google.charts.setOnLoadCallback(function () {
                var data = google.visualization.arrayToDataTable([
                    ['', 'Sales Growth'],
                    ['10 Years', d.SalesGrowth_10_Years],
                    ['7 Years', d.SalesGrowth_7_Years],
                    ['5 Years', d.SalesGrowth_5_Years],
                    ['3 Years', d.SalesGrowth_3_Years],
                    ['Current', d.SalesGrowth],
                ]);

                var options = {
                    chart: {
                        title: 'Company Performance',
                        subtitle: 'Sales Growth',
                    }
                };

                var chart = new google.charts.Bar(document.getElementById('columnchart_material_' + d.rnd));

                chart.draw(data, google.charts.Bar.convertOptions(options));
            });
        }).always(function () {
        });
    });

    $("body").on("click", "#lnkAddNew", function () {
        _COMPANY.add(0);
    });

    $("body").on("click", "#btnSave", function () {
        var $this = $(this);
        var $tr = $this.parents("tr:first");
        var companyId = $("#CompanyID", $tr).val();
        var $frm = $("#frm" + companyId);
        var arr = $frm.serializeArray();
        var url = apiUrl("/Company/Save");
        var d = {};
        for (var i = 0; i < arr.length; i++) {
            d[arr[i].name] = arr[i].value;
        }
        d.IsArchive = $("#chkIsArchive", $tr)[0].checked;
        d.IsBookMark = $("#chkIsBookMark", $tr)[0].checked;
        console.log('d=', d);
        $.ajax({
            "url": url,
            "cache": false,
            "type": "POST",
            contentType: 'application/json; charset=utf-8',
            data: JSON.stringify(d)
        }).done(function (json) {
            console.log('btnSave=', json);
            var $trDisp = $("#tr" + companyId);
            $("#grid-template").tmpl(json).insertBefore($tr);
            $trDisp.remove();
            $tr.remove();
        }).always(function () {
        });
    });

    $("body").on("click", "#btnCancel", function () {
        var $this = $(this);
        var $tr = $this.parents("tr:first");
        $tr.remove();
    });

    $("body").on("click", "#lnkRefresh", function () {
        $tbl.flexReload2();
    });

    var $lnkScreenerDownload = $("#lnkScreenerDownload");

    $lnkScreenerDownload.click(function () {
        _COMPANY.startScreener();
    });

    var $btnScreenerUpdateCSV = $("#btnScreenerUpdateCSV");
    $btnScreenerUpdateCSV.click(function () {
        var $screener_csv = $("#screener_csv");
        console.log('screener_csv=', $screener_csv.val());
        var url = apiUrl("/Company/UpdateScreenerCSV");
        var d = { "csv": $screener_csv.val() };
        $.ajax({
            "url": url,
            "cache": false,
            "type": "POST",
            contentType: 'application/json; charset=utf-8',
            data: JSON.stringify(d)
        }).done(function (json) {
            var html = $("#screener_index").val() + ' of ' + $("#screener_total").val() + " - " + json.CompanyName;
            $("#screener_csv_log").html(html);
            $tbl.flexReload2();
        }).always(function () {
        });
    });

    $("body").on("click", "#btnNSEUpdateCSV", function (event) {
        var $nse_csv = $("#nse_csv");
        console.log('nse_csv=', $nse_csv.val());
        var url = apiUrl("/Company/UpdateNSECSV");
        var d = { "csv": $nse_csv.val() };
        $.ajax({
            "url": url,
            "cache": false,
            "type": "POST",
            contentType: 'application/json; charset=utf-8',
            data: JSON.stringify(d)
        }).done(function (json) {
            var html = $("#nse_index").val() + ' of ' + $("#nse_total").val() + " - " + json.CompanyName;
            $("#nse_csv_log").html(html);
            $tbl.flexReload2();
        }).always(function () {
        });
    });


    var $lnkMoneyControlDownload = $("#lnkMoneyControlDownload");

    $lnkMoneyControlDownload.click(function () {
        _COMPANY.startMoneyControl();
    });

    var $btnMoneyControlUpdateCSV = $("#btnMoneyControlUpdateCSV");
    $btnMoneyControlUpdateCSV.click(function () {
        var $moneycontrol_csv = $("#moneycontrol_csv");
        console.log('moneycontrol_csv=', $moneycontrol_csv.val());
        var url = apiUrl("/Company/UpdateMoneyControlCSV");
        var d = { "csv": $moneycontrol_csv.val() };
        $.ajax({
            "url": url,
            "cache": false,
            "type": "POST",
            contentType: 'application/json; charset=utf-8',
            data: JSON.stringify(d)
        }).done(function (json) {
            var html = $("#moneycontrol_index").val() + ' of ' + $("#moneycontrol_total").val() + " - " + json.CompanyName;
            $("#moneycontrol_csv_log").html(html);
            $tbl.flexReload2();
        }).always(function () {
        });
    });

});