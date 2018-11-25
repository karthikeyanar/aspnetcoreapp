function Category() {
    var self = this;

    this.add = function (categoryId) {
        if (categoryId > 0) {
            var $tr = $("#tr" + categoryId);
            var arr = [];
            arr.push({ "name": "CategoryID", "value": categoryId });
            arr.push({ "name": "PageSize", "value": 1 });
            arr.push({ "name": "PageIndex", "value": 1 });
            arr.push({ "name": "SortName", "value": "CategoryID" });
            arr.push({ "name": "SortOrder", "value": "asc" });
            $.ajax({
                type: 'GET',
                url: apiUrl('/Category/List'),
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
            var $tbl = $("#tblCategory");
            var json = { "rows": [] };
            json.rows.push({ "CategoryID": 0, "CategoryName": "", "IsArchive": false, "IsBookMark": false });
            $("#edit-template").tmpl(json).prependTo($tbl);
            $(":input[name='CategoryName']", $("#trEdit" + categoryId)).focus();
        }
    }

}

var _CATEGORY = new Category();

$(function () {
    var $tbl = $("#tblCategory");

    $tbl.flexigrid2({
        usepager: true,
        useBoxStyle: false,
        url: apiUrl("/Category/List"),
        rpOptions: [5, 10, 20, 30, 40, 50, 100, 200, 500, 1000],
        rp: 1000,
        onSubmit: function (p) {
            p.params = [];
            var chk = $("#chkIsBookMark")[0];
            if (chk.checked) {
                p.params.push({ "name": "IsBookMark", "value": true })
            }
            chk = $("#chkIsArchive")[0];
            if (chk.checked) {
                p.params.push({ "name": "IsArchive", "value": true })
            }
        },
        onSuccess: function (t, g) { },
        onTemplate: function (data) {
            _CATEGORY.category_json = data.rows;
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
        sortname: "CategoryName",
        sortorder: "asc",
        autoload: true,
        height: 0,
        applyFixedHeader: true
    });

    $("body").on("click", ".edit-row", function () {
        var $this = $(this);
        var $tr = $this.parents("tr:first");
        var categoryId = $("#CategoryID", $tr).val();
        _CATEGORY.add(categoryId);
    });

    $("body").on("click", ".delete-row", function () {
        var $this = $(this);
        var $tr = $this.parents("tr:first");
        var categoryId = $("#CategoryID", $tr).val();
        if (confirm('Are you sure?')) {
            $("#tr" + categoryId).remove();
            $("#trEdit" + categoryId).remove();
            var url = apiUrl("/Category/Delete?id=" + categoryId);
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
        _CATEGORY.add(0);
    });

    $("body").on("click", "#btnSave", function () {
        var $this = $(this);
        var $tr = $this.parents("tr:first");
        var categoryId = $("#CategoryID", $tr).val();
        var $frm = $("#frm" + categoryId);
        var arr = $frm.serializeArray();
        var url = apiUrl("/Category/Save");
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
            var $trDisp = $("#tr" + categoryId);
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

    $("body").on("click", "#frmSearch #chkIsBookMark", function () {
        $tbl.flexReload2();
    });

    $("body").on("click", "#frmSearch #chkIsArchive", function () {
        $tbl.flexReload2();
    });

});