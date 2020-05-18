
function Portfolio() {
    var self = this;

    this.index = -1;
    this._json = null; 

    this.add = function (id) {
        if (id > 0) {
            var $tr = $("#tr" + id);
            var arr = [];
            arr.push({ "name": "ID", "value": id });
            arr.push({ "name": "PageSize", "value": 1 });
            arr.push({ "name": "PageIndex", "value": 1 });
            arr.push({ "name": "SortName", "value": "p.PortfolioTransactionID" });
            arr.push({ "name": "SortOrder", "value": "asc" });
            $.ajax({
                type: 'GET',
                url: apiUrl('/Portfolio/List'),
                cache: false,
                data: arr,
                dataType: 'json',
                success: function (json) {
                    console.log(json);
                    if (json.rows.length > 0) {
                        $("#edit-template").tmpl(json).insertAfter($tr);
                    }
                    var $editRow = $("#trEdit" + id);
                    console.log('$tr2=',$editRow[0]);
                    self.applyPlugins($editRow);
                },
                error: function (data) {
                    console.log('error data=', data);
                }
            });
        } else {
            var $tbl = $("#tblPortfolio");
            var json = { "rows": [] };
            json.rows.push({ "PortfolioTransactionID": 0, "CompanyName": "","TransactionTypeID": 1,"TransactionDate":"","Quantity":"","CostPerShare":"" });
            $("#edit-template").tmpl(json).prependTo($tbl);
            var $tr = $("#trEdit" + id);
            $(":input[name='CompanyName']",$tr).focus();
            console.log('$tr1=',$tr[0]);
            self.applyPlugins($tr);
        }
    }

    this.applyPlugins = function($tr) {
        console.log('$tr=',$tr[0]);
        console.log('$("#CompanyID",$tr)=',$("#CompanyID",$tr)[0]);
        var $companyId = $("#CompanyID",$tr);
        var cid = cInt($companyId.val());
        var cname = $companyId.attr('cname');
        $companyId.val("").select2({
            placeholder: "Select Company",
            minimumInputLength: 0,
            maximumSelectionSize: 1000,
            minimumResultsForSearch: 0,
            multiple: false,
            allowClear: false,
            delay: 300,
            width: "500px",
            query: function (query) {
                $.getJSON(apiUrl("/Company/FindCompanies?term=" + query.term), function (data) {
                    //var data = [];
                    //for(var i = 0;i<100;i++){
                    //    data.push({"id":"Contact_"+i,"label":"Contact_"+i});
                    //}
                    var callback = function (data, page) {
                        var s2data = [];
                        $.each(data, function (i, d) {
                            s2data.push({ "id": d.id, "text": d.label });
                        });
                        return { results: s2data };
                    }
                    query.callback(callback(data, query.page));
                });
            }
        }).on("change", function (e) {
        });
        if(cid>0){
            var options = [];
            options.push({ "id": cid,"text": cname });
            console.log(options);
            $companyId.select2("data",{ "id": cid,"text": cname });
        }
        $("#TransactionTypeID",$tr).val($("#TransactionTypeID",$tr).attr('val'));
        var $TransactionDate = $("#TransactionDate",$tr);
        $TransactionDate.datepicker({
            autoclose: true,
            format: 'dd/M/yyyy'
        }).on('changeDate', function (selected) {
        });
    
    }

}

var _PORTFOLIO = new Portfolio();

$(function () {
    var $tbl = $("#tblPortfolio");

    $tbl.flexigrid2({
        usepager: true,
        useBoxStyle: false,
        url: apiUrl("/Portfolio/List"),
        rpOptions: [10, 20, 30, 40, 50, 100, 200, 500, 1000,2000],
        rp: 50,
        onSubmit: function (p) {
            p.params = [];
        },
        onSuccess: function (t, g) { },
        onTemplate: function (data) {
            _PORTFOLIO._json = data.rows;
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

    $("body").on("click", ".edit-row", function () {
        var $this = $(this);
        var $tr = $this.parents("tr:first");
        var id = $("#PortfolioTransactionID", $tr).val();
        console.log('id=',id);
        _PORTFOLIO.add(id);
    });

    $("body").on("click", ".delete-row", function () {
        var $this = $(this);
        var $tr = $this.parents("tr:first");
        var id = $("#PortfolioTransactionID", $tr).val();
        if (confirm('Are you sure?')) {
            $("#tr" + id).remove();
            $("#trEdit" + id).remove();
            var url = apiUrl("/Portfolio/Delete?id=" + id);
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
        _PORTFOLIO.add(0);
    });

    $("body").on("click", "#btnSave", function () {
        var $this = $(this);
        var $tr = $this.parents("tr:first");
        var id = $("#PortfolioTransactionID", $tr).val();
        var $frm = $("#frm" + id);
        var arr = $frm.serializeArray();
        var url = apiUrl("/Portfolio/Save");
        var errorMsg = '';
        var d = {};
        for (var i = 0; i < arr.length; i++) {
            switch (arr[i].name) {
                case 'CompanyID':
                    if(cInt(arr[i].value)<=0){
                        errorMsg += 'Company is required\n';
                    }
                    break;
                case 'TransactionTypeID':
                    if(cInt(arr[i].value)<=0){
                        errorMsg += 'Transaction Type is required\n';
                    }
                    break;
                case 'TransactionDate':
                    if(cString(arr[i].value)==''){
                        errorMsg += 'Date is required\n';
                    }
                    break;
                case 'Quantity':
                    if(cFloat(arr[i].value)<=0){
                        errorMsg += 'Quantity is required\n';
                    }
                    break;
                case 'CostPerShare':
                    if(cFloat(arr[i].value)<=0){
                        errorMsg += 'Cost Per Share is required\n';
                    }
                    break;
                default:
                    break;
            }
            d[arr[i].name] = arr[i].value;
        }
        console.log('d=', d);
        if(errorMsg!=''){
            alert(errorMsg);
        } else {
            $.ajax({
                "url": url,
                "cache": false,
                "type": "POST",
                contentType: 'application/json; charset=utf-8',
                data: JSON.stringify(d)
            }).done(function (json) {
                console.log('btnSave=', json);
                var $trDisp = $("#tr" + id);
                $("#grid-template").tmpl(json).insertBefore($tr);
                $trDisp.remove();
                $tr.remove();
            }).always(function () {
            });
        }
    });

    $("body").on("click", "#btnCancel", function () {
        var $this = $(this);
        var $tr = $this.parents("tr:first");
        $tr.remove();
    });

    $("body").on("click", "#lnkRefresh", function () {
        $tbl.flexReload2();
    });

});