/** 货币格式化函数 **/
function formatCurrency(num) {
    num = num.toString().replace(/\$|\,/g,'');
    if(isNaN(num))
        num = "0";
    sign = (num == (num = Math.abs(num)));
    num = Math.floor(num*100+0.50000000001);
    cents = num%100;
    num = Math.floor(num/100).toString();
    if(cents<10)
        cents = "0" + cents;
    for (var i = 0; i < Math.floor((num.length-(1+i))/3); i++)
        num = num.substring(0,num.length-(4*i+3))+','+
            num.substring(num.length-(4*i+3));
    return (((sign)?'':'-')  + num + '.' + cents);
}
/** 还原货币格式化函数 **/
function restoreFormatCurrency(num){
    var num1=num.replace(',','').replace(/,/g,'');
    return num1;
}

/**
 *
 * @param tabName
 * @param tabTitle
 * @param isClose
 * @param url
 * @param isActivate
 */
function addTab(tabName, tabTitle, isClose, url, isActivate) {
    var t = tabName.add({
        id:tabTitle,
        title:tabTitle,
        iconCls:'tabs',
        html:url,
        closable:isClose
    });
    if (isActivate) {
        tabName.activate(t);
    }
}

/**
 * 设置有效、无效
 * @param value
 */
function setYesOrNo(val) {
    if (val == true) {
        return '是'
    }
    return '否'
}

/**
 * 设置有效、无效
 * @param value
 */
function setEnabled(val) {
    if (val == true) {
        return '有效'
    }
    return '无效'
}

/**
 * 设置站名
 * @param value
 */
function setStation(val) {
    if (val && val.stationName) {
        return val.stationName
    }
    return ''
}

Array.prototype.remove = function(from, to) {
    var rest = this.slice((to || from) + 1 || this.length);
    this.length = from < 0 ? this.length + from : from;
    return this.push.apply(this, rest);
};

/**
 * 定义选择树
 */
Ext.define("Ext.ux.ComboBoxTree", {
        extend : "Ext.form.field.Picker",
        requires : ["Ext.tree.Panel"],
        initComponent : function() {
            var self = this;
            Ext.apply(self, {
                fieldLabel : self.fieldLabel,
                labelWidth : self.labelWidth,
                blankText:self. blankText,
                hiddenName:self.hiddenName
            });
            self.callParent();
        },
        createPicker : function(){
            var self = this;

            var store = Ext.create('Ext.data.TreeStore', {
                //autoLoad: true,
                remoteSort: true,
                proxy: {
                    type: 'ajax',
                    url: self.storeUrl
                },
                root: {
                    text: self.rootText,
                    id: self.rootId
                },
                folderSort: true,
                sorters: [{
                    property: 'text',
                    direction: 'ASC'
                }]
            });

            self.picker = new Ext.tree.Panel({
                height : 280,
                autoScroll : true,
                floating : true,
                focusOnToFront : false,
                shadow : true,
                ownerCt : this.ownerCt,
                useArrows : true,
                store : store,
                rootVisible : true
            });
            self.picker.on ('checkchange',function(node, checked) {
                var records = self.picker.getView().getChecked(), texts = [], ids = [];
                Ext.Array.each(records, function(rec) {
                    texts.push(rec.get('text'));
                    ids.push(rec.get('id'));
                });
                self.setValue(ids.join(','));// 隐藏值ID
                self.setRawValue(texts.join(';'));// 显示值
            });

            self.picker.on ('beforequery', function(q, o) {

            });
            self.picker.on ('itemclick', function(view,rec) {
                if(self.selectClick){
                    if(rec){
                        if(self.multiSelect){
                            var names =[],values= [];
                            if(self.getValue()){
                               var vs =  self.getValue().split(",")
                               for(var i=0;i<vs.length;i++){
                                   values.push(vs[i])
                               }
                            }
                            if(self.getRawValue()){
                                var rvs =  self.getRawValue().split(",")
                                for(var i=0;i<rvs.length;i++){
                                    names.push(rvs[i])
                                }
                            }
                            var tagName = false
                            Ext.Array.each(names, function(obj) {
                                if(rec.get('text')==obj){
                                    tagName = true
                                }
                            });
                            if(tagName){
                                for(var i=0;i<names.length;i++){
                                    if(rec.get('text')==names[i]){
                                        names.remove(i)
                                    }
                                }
                            }else{
                                names.push(rec.get('text'));
                            }

                            var tagValue = false
                            Ext.Array.each(values, function(obj) {
                                if(rec.get('id')==obj){
                                    tagValue = true
                                }
                            });
                            if(tagValue){
                                for(var i=0;i<values.length;i++){
                                    if(rec.get('id')==values[i]){
                                        values.remove(i)
                                    }
                                }
                            }else{
                                values.push(rec.get('id'));
                            }
                            self.setValue(values.join(','));
                            self.setRawValue(names.join(','));
                        }else{
                            self.setValue(rec.get('id'));
                            self.setRawValue(rec.get("text"));
                            self.collapse();
                        }
                    }
                }
            });
            self.picker.on ('click', function(view,rec) {

            });

            return self.picker;
        },

        alignPicker : function() {
            var me = this, picker, isAbove, aboveSfx = '-above';
            if (this.isExpanded) {
                picker = me.getPicker();
                if (me.matchFieldWidth) {
                    picker.setWidth(me.bodyEl.getWidth());
                }
                if (picker.isFloating()) {
                    picker.alignTo(me.inputEl, "", me.pickerOffset);// ""->tl
                    isAbove = picker.el.getY() < me.inputEl.getY();
                    me.bodyEl[isAbove ? 'addCls' : 'removeCls'](me.openCls + aboveSfx);
                    picker.el[isAbove ? 'addCls' : 'removeCls'](picker.baseCls + aboveSfx);
                }
            }
        },setRawValue: function(value) {
            var me = this;
            value = Ext.value(value, '');
            me.rawValue = value;
            if (me.inputEl) {
                me.inputEl.dom.value = value;
            }
            return value;
        },setValue: function(value, doSelect) {
            this.value = value;
            return value;
        },getValue: function() {
            var me = this;
            return me.value;
        },getSubmitValue: function() {
            return this.getValue();
        }
});


Ext.view.TableChunker.metaRowTpl = [
    '<tr class="' + Ext.baseCSSPrefix + 'grid-row {addlSelector} {[this.embedRowCls()]}" {[this.embedRowAttr()]}>',
    '<tpl for="columns">',
    '<td class="{cls} ' + Ext.baseCSSPrefix + 'grid-cell ' + Ext.baseCSSPrefix + 'grid-cell-{columnId} {{id}-modified} {{id}-tdCls} {[this.firstOrLastCls(xindex, xcount)]}" {{id}-tdAttr}><div class="' + Ext.baseCSSPrefix + 'grid-cell-inner" style="{{id}-style}; text-align: {align};">{{id}}</div></td>',
    '</tpl>',
    '</tr>'
];

Ext.core.Element.prototype.unselectable = function() {
    var me = this;
    if (me.dom.className.match(/(x-grid-table|x-grid-view)/)) {
        return me;
    }
    me.dom.unselectable = "on";
    me.swallowEvent("selectstart", true);
    me.applyStyles("-moz-user-select:none;-khtml-user-select:none;");
    me.addCls(Ext.baseCSSPrefix + 'unselectable');
    return me;
};
Ext.apply(Ext.form.field.VTypes,{
    cellphone: function(val){
        try{
            var sj = /^(((13[0-9]{1})|159|(15[0-9]{1}))+\d{8})$/;
            var xlt = /^\d{7,12}$/;
            if(!(sj.test(val) || xlt.test(val))){
                return false
            }
            return true;
        }catch(e){
            return false;
        }
    },
    cellphoneText:'请输入合法的手机号码'
});