
function Company() {
    var self = this;

    this.index = -1;
    this.company_json = null;

    this.startInvesting = function () {
        console.log('self.index=', self.index);
        var symbols = '';
        for (var i = 0; i < self.company_json.length; i++) {
            var c = self.company_json[i];
            symbols += c.CompanyID + '|' + c.InvestingUrl + '|' + formatDate(c.LastTradingDate, 'DD/MM/YYYY') + '|' + formatDate(new Date(), 'DD/MM/YYYY') + ',';
        }
        if (symbols != '') {
            symbols = symbols.substring(0, symbols.length - 1);
        }
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
    var $tbl = $("#tblCompany");

    $tbl.flexigrid2({
        usepager: true,
        useBoxStyle: false,
        url: apiUrl("/Company/List"),
        rpOptions: [5, 10, 20, 30, 40, 50, 100, 200, 500, 1000],
        rp: 5,
        onSubmit: function (p) {
            p.params = [];
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

    var $lnkInvestingDownload = $("#lnkInvestingDownload");

    $lnkInvestingDownload.click(function () {
        _COMPANY.startInvesting();
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
        }).always(function () {
        });
    });

    $("body").on("click", ".edit-row", function () {
        var $this = $(this);
        var $tr = $this.parents("tr:first");
        var companyId = $("#CompanyID", $tr).val();
        _COMPANY.add(companyId);
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
        }).always(function () {
        });
    });

});