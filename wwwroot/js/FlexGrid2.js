(function ($) {
    $.addFlex2 = function (t, p) {
        if (t.grid) { return false; }
        p = $.extend({
            url: false
			, method: 'POST'
			, dataType: 'json'
			, usepager: false
            , onRPSelectElement: false
            , onPaginationElement: false
            , onPaginationStatusElement: false
			, page: 1
            , rp: 10
			, useRp: true
			, rpOptions: [10, 20, 30, 40, 50, 100, 200]
			, autoload: true
			, sortname: ''
			, sortorder: ''
			, onSubmit: false
			, onTemplate: false
        }, p);
        var g = {
            changeSort: function (th) {
                if (p.sortname == $(th).attr('sortname')) {
                    if (p.sortorder == 'asc') { p.sortorder = 'desc'; }
                    else { p.sortorder = 'asc'; }
                }
                $(th).addClass('sorted').siblings().removeClass('sorted');
                $(th).addClass('sort').removeClass('asc').removeClass('desc').addClass(p.sortorder);
                p.sortname = $(th).attr('sortname');
                p.page = 1;
                this.populate();
            }
			, params: new Array()
			, populate: function () {
			    console.log('p.rp=', p.rp);
			    if (p.onSubmit) {
			        p.onSubmit(p);
			    }
			    if (!p.url) { return false; }
			    //if ($.browser.opera) { $(t).css('visibility', 'hidden'); }
			    if (!p.page) { p.newp = 1; }
			    if (p.page > p.pages) { p.page = p.pages; }
			    var param = [];
			    param = [
                 { name: 'PageIndex', value: p.page }
                , { name: 'PageSize', value: p.rp }
                , { name: 'SortName', value: p.sortname }
                , { name: 'SortOrder', value: p.sortorder }
			    ];
			    if (p.params) {
			        for (var pi = 0; pi < p.params.length; pi++) { param[param.length] = p.params[pi]; }
			    }
			    g.params = param;

			    $.ajax({
			        type: p.method,
			        url: p.url,
			        cache: false,
			        data: param,
			        dataType: p.dataType,
			        success: function (data) {
			            if (p.onTemplate) {
			                p.onTemplate(data);
			            }
			            if (p.usepager == true && p.onPaginationElement) {
			                var $paginationElement = p.onPaginationElement();
			                $paginationElement.twbsPagination({
			                    total: data.total,
			                    rowsPerPage: p.rp,
			                    startPage: p.page,
			                    currentPage: p.page,
			                    onRender: function (status) {
			                        if (p.onPaginationStatusElement) {
			                            var $status = p.onPaginationStatusElement();
			                            $status.html(status);
			                        }
			                    },
			                    onPageClick: function (page) {
			                        p.page = page;
			                        g.populate();
			                    }
			                });
			            }
			        },
			        error: function (data) {
			            try { if (p.onError) { p.onError(data); } } catch (e) { }
			        }
			    });
			}
            , setupSort: function () {
                $('thead tr th', t).each(function () {
                    var thdiv = document.createElement('div');
                    thdiv.innerHTML = "<span>" + this.innerHTML + "</span>";
                    if ($(this).attr('sortname')) {
                        $(this)
						.addClass("issortcol")
						.click(function (e) { g.changeSort(this); });
                        var sname = $(this).attr('sortname');
                        if (sname == p.sortname) {
                            $(this).addClass("sorted").addClass("sort");
                            if (p.sortorder == '') {
                                p.sortorder = 'asc';
                            }
                            $(this).addClass(p.sortorder);
                            $("span", thdiv).addClass('s' + p.sortorder);
                        }
                    }
                });
            }
            , setupRP: function () {
                if (p.onRPSelectElement) {
                    var $element = p.onRPSelectElement();
                    var ddl = $element[0];
                    console.log('$element=', $element);
                    ddl.options.length = null;
                    var listItem = null;
                    for (var i = 0; i < p.rpOptions.length; i++) {
                        listItem = new Option(p.rpOptions[i], p.rpOptions[i], false, false);
                        //console.log(listItem);
                        ddl.options[ddl.options.length] = listItem;
                    };
                    ddl.value = p.rp;
                    $element.unbind('change').change(function () {
                        p.page = 1;
                        p.rp = this.value;
                        g.populate();
                    });
                }
            }
        };

        g.setupRP();
        g.setupSort();

        t.p = p;
        t.grid = g;
        if (p.url && p.autoload) {
            g.populate();
        }
        return t;
    };

    var docloaded = false;
    $(document).ready(function () { docloaded = true });
    $.fn.flexigrid2 = function (p) {
        return this.each(function () {
            if (!docloaded) {
                var t = this;
                $(document).ready
					(
						function () {
						    $.addFlex2(t, p);
						}
					);
            } else {
                $.addFlex2(this, p);
            }
        });
    };
    $.fn.flexReload2 = function (p) {
        return this.each(function () {
            if (this.grid && this.p.url) {
                this.p.page = 1;
                this.grid.populate();
            }
        });
    };
})(jQuery);