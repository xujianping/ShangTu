/**
 * @class Ext.form.field.Date
 * @extends Ext.form.field.Picker

 Provides a date input field with a {@link Ext.picker.Date date picker} dropdown and automatic date
 validation.

 This field recognizes and uses the JavaScript Date object as its main {@link #value} type. In addition,
 it recognizes string values which are parsed according to the {@link #format} and/or {@link #altFormats}
 configs. These may be reconfigured to use date formats appropriate for the user's locale.

 The field may be limited to a certain range of dates by using the {@link #minValue}, {@link #maxValue},
 {@link #disabledDays}, and {@link #disabledDates} config parameters. These configurations will be used both
 in the field's validation, and in the date picker dropdown by preventing invalid dates from being selected.
 {@img Ext.form.Date/Ext.form.Date.png Ext.form.Date component}
 #Example usage:#

 Ext.create('Ext.form.Panel', {
 width: 300,
 bodyPadding: 10,
 title: 'Dates',
 items: [{
 xtype: 'datefield',
 anchor: '100%',
 fieldLabel: 'From',
 name: 'from_date',
 maxValue: new Date()  // limited to the current date or prior
 }, {
 xtype: 'datefield',
 anchor: '100%',
 fieldLabel: 'To',
 name: 'to_date',
 value: new Date()  // defaults to today
 }],
 renderTo: Ext.getBody()
 });

 #Date Formats Examples#

 This example shows a couple of different date format parsing scenarios. Both use custom date format
 configurations; the first one matches the configured `format` while the second matches the `altFormats`.

 Ext.create('Ext.form.Panel', {
 renderTo: Ext.getBody(),
 width: 300,
 bodyPadding: 10,
 title: 'Dates',
 items: [{
 xtype: 'datefield',
 anchor: '100%',
 fieldLabel: 'Date',
 name: 'date',
 // The value matches the format; will be parsed and displayed using that format.
 format: 'm d Y',
 value: '2 4 1978'
 }, {
 xtype: 'datefield',
 anchor: '100%',
 fieldLabel: 'Date',
 name: 'date',
 // The value does not match the format, but does match an altFormat; will be parsed
 // using the altFormat and displayed using the format.
 format: 'm d Y',
 altFormats: 'm,d,Y|m.d.Y',
 value: '2.4.1978'
 }]
 });

 * @constructor
 * Create a new Date field
 * @param {Object} config
 *
 * @xtype datefield
 * @markdown
 * @docauthor Jason Johnston <jason@sencha.com>
 */
Ext.define('Ext.form.field.DateTime', {
    extend:'Ext.form.field.Picker',
    alias:'widget.datetimefield',
    requires:['Ext.picker.DateTime'],

    /**
     * @cfg {String} format
     * The default date format string which can be overriden for localization support.  The format must be
     * valid according to {@link Ext.Date#parse} (defaults to <tt>'m/d/Y'</tt>).
     */
    format:"m/d/Y",
    /**
     * @cfg {String} altFormats
     * Multiple date formats separated by "<tt>|</tt>" to try when parsing a user input value and it
     * does not match the defined format (defaults to
     * <tt>'m/d/Y|n/j/Y|n/j/y|m/j/y|n/d/y|m/j/Y|n/d/Y|m-d-y|m-d-Y|m/d|m-d|md|mdy|mdY|d|Y-m-d|n-j|n/j'</tt>).
     */
    altFormats:"m/d/Y|n/j/Y|n/j/y|m/j/y|n/d/y|m/j/Y|n/d/Y|m-d-y|m-d-Y|m/d|m-d|md|mdy|mdY|d|Y-m-d|n-j|n/j",
    /**
     * @cfg {String} disabledDaysText
     * The tooltip to display when the date falls on a disabled day (defaults to <tt>'Disabled'</tt>)
     */
    disabledDaysText:"Disabled",
    /**
     * @cfg {String} disabledDatesText
     * The tooltip text to display when the date falls on a disabled date (defaults to <tt>'Disabled'</tt>)
     */
    disabledDatesText:"Disabled",
    /**
     * @cfg {String} minText
     * The error text to display when the date in the cell is before <tt>{@link #minValue}</tt> (defaults to
     * <tt>'The date in this field must be after {minValue}'</tt>).
     */
    minText:"The date in this field must be equal to or after {0}",
    /**
     * @cfg {String} maxText
     * The error text to display when the date in the cell is after <tt>{@link #maxValue}</tt> (defaults to
     * <tt>'The date in this field must be before {maxValue}'</tt>).
     */
    maxText:"The date in this field must be equal to or before {0}",
    /**
     * @cfg {String} invalidText
     * The error text to display when the date in the field is invalid (defaults to
     * <tt>'{value} is not a valid date - it must be in the format {format}'</tt>).
     */
    invalidText:"{0} is not a valid date - it must be in the format {1}",
    /**
     * @cfg {String} triggerCls
     * An additional CSS class used to style the trigger button.  The trigger will always get the
     * class <tt>'x-form-trigger'</tt> and <tt>triggerCls</tt> will be <b>appended</b> if specified
     * (defaults to <tt>'x-form-date-trigger'</tt> which displays a calendar icon).
     */
    triggerCls:Ext.baseCSSPrefix + 'form-date-trigger',
    /**
     * @cfg {Boolean} showToday
     * <tt>false</tt> to hide the footer area of the Date picker containing the Today button and disable
     * the keyboard handler for spacebar that selects the current date (defaults to <tt>true</tt>).
     */
    showToday:true,
    /**
     * @cfg {Date/String} minValue
     * The minimum allowed date. Can be either a Javascript date object or a string date in a
     * valid format (defaults to undefined).
     */
    /**
     * @cfg {Date/String} maxValue
     * The maximum allowed date. Can be either a Javascript date object or a string date in a
     * valid format (defaults to undefined).
     */
    /**
     * @cfg {Array} disabledDays
     * An array of days to disable, 0 based (defaults to undefined). Some examples:<pre><code>
     // disable Sunday and Saturday:
     disabledDays:  [0, 6]
     // disable weekdays:
     disabledDays: [1,2,3,4,5]
     * </code></pre>
     */
    /**
     * @cfg {Array} disabledDates
     * An array of "dates" to disable, as strings. These strings will be used to build a dynamic regular
     * expression so they are very powerful. Some examples:<pre><code>
     // disable these exact dates:
     disabledDates: ["03/08/2003", "09/16/2003"]
     // disable these days for every year:
     disabledDates: ["03/08", "09/16"]
     // only match the beginning (useful if you are using short years):
     disabledDates: ["^03/08"]
     // disable every day in March 2006:
     disabledDates: ["03/../2006"]
     // disable every day in every March:
     disabledDates: ["^03"]
     * </code></pre>
     * Note that the format of the dates included in the array should exactly match the {@link #format} config.
     * In order to support regular expressions, if you are using a {@link #format date format} that has "." in
     * it, you will have to escape the dot when restricting dates. For example: <tt>["03\\.08\\.03"]</tt>.
     */

    /**
     * @cfg {String} submitFormat The date format string which will be submitted to the server.
     * The format must be valid according to {@link Ext.Date#parse} (defaults to <tt>{@link #format}</tt>).
     */

    // in the absence of a time value, a default value of 12 noon will be used
    // (note: 12 noon was chosen because it steers well clear of all DST timezone changes)
    initTime:'12', // 24 hour format

    initTimeFormat:'H',

    matchFieldWidth:false,
    /**
     * @cfg {Number} startDay
     * Day index at which the week should begin, 0-based (defaults to 0, which is Sunday)
     */
    startDay:0,

    initComponent:function () {
        var me = this,
            isString = Ext.isString,
            min, max;

        min = me.minValue;
        max = me.maxValue;
        if (isString(min)) {
            me.minValue = me.parseDate(min);
        }
        if (isString(max)) {
            me.maxValue = me.parseDate(max);
        }
        me.disabledDatesRE = null;
        me.initDisabledDays();

        me.callParent();
    },

    initValue:function () {
        var me = this,
            value = me.value;

        // If a String value was supplied, try to convert it to a proper Date
        if (Ext.isString(value)) {
            me.value = me.rawToValue(value);
        }

        me.callParent();
    },

    // private
    initDisabledDays:function () {
        if (this.disabledDates) {
            var dd = this.disabledDates,
                len = dd.length - 1,
                re = "(?:";

            Ext.each(dd, function (d, i) {
                re += Ext.isDate(d) ? '^' + Ext.String.escapeRegex(d.dateFormat(this.format)) + '$' : dd[i];
                if (i !== len) {
                    re += '|';
                }
            }, this);
            this.disabledDatesRE = new RegExp(re + ')');
        }
    },

    /**
     * Replaces any existing disabled dates with new values and refreshes the Date picker.
     * @param {Array} disabledDates An array of date strings (see the <tt>{@link #disabledDates}</tt> config
     * for details on supported values) used to disable a pattern of dates.
     */
    setDisabledDates:function (dd) {
        var me = this,
            picker = me.picker;

        me.disabledDates = dd;
        me.initDisabledDays();
        if (picker) {
            picker.setDisabledDates(me.disabledDatesRE);
        }
    },

    /**
     * Replaces any existing disabled days (by index, 0-6) with new values and refreshes the Date picker.
     * @param {Array} disabledDays An array of disabled day indexes. See the <tt>{@link #disabledDays}</tt>
     * config for details on supported values.
     */
    setDisabledDays:function (dd) {
        var picker = this.picker;

        this.disabledDays = dd;
        if (picker) {
            picker.setDisabledDays(dd);
        }
    },

    /**
     * Replaces any existing <tt>{@link #minValue}</tt> with the new value and refreshes the Date picker.
     * @param {Date} value The minimum date that can be selected
     */
    setMinValue:function (dt) {
        var me = this,
            picker = me.picker,
            minValue = (Ext.isString(dt) ? me.parseDate(dt) : dt);

        me.minValue = minValue;
        if (picker) {
            picker.minText = Ext.String.format(me.minText, me.formatDate(me.minValue));
            picker.setMinDate(minValue);
        }
    },

    /**
     * Replaces any existing <tt>{@link #maxValue}</tt> with the new value and refreshes the Date picker.
     * @param {Date} value The maximum date that can be selected
     */
    setMaxValue:function (dt) {
        var me = this,
            picker = me.picker,
            maxValue = (Ext.isString(dt) ? me.parseDate(dt) : dt);

        me.maxValue = maxValue;
        if (picker) {
            picker.maxText = Ext.String.format(me.maxText, me.formatDate(me.maxValue));
            picker.setMaxDate(maxValue);
        }
    },

    /**
     * Runs all of Date's validations and returns an array of any errors. Note that this first
     * runs Text's validations, so the returned array is an amalgamation of all field errors.
     * The additional validation checks are testing that the date format is valid, that the chosen
     * date is within the min and max date constraints set, that the date chosen is not in the disabledDates
     * regex and that the day chosed is not one of the disabledDays.
     * @param {Mixed} value The value to get errors for (defaults to the current field value)
     * @return {Array} All validation errors for this field
     */
    getErrors:function (value) {
        var me = this,
            format = Ext.String.format,
            clearTime = Ext.Date.clearTime,
            errors = me.callParent(arguments),
            disabledDays = me.disabledDays,
            disabledDatesRE = me.disabledDatesRE,
            minValue = me.minValue,
            maxValue = me.maxValue,
            len = disabledDays ? disabledDays.length : 0,
            i = 0,
            svalue,
            fvalue,
            day,
            time;

        value = me.formatDate(value || me.processRawValue(me.getRawValue()));

        if (value === null || value.length < 1) { // if it's blank and textfield didn't flag it then it's valid
            return errors;
        }

        svalue = value;
        value = me.parseDate(value);
        if (!value) {
            errors.push(format(me.invalidText, svalue, me.format));
            return errors;
        }

        time = value.getTime();
        if (minValue && time < clearTime(minValue).getTime()) {
            errors.push(format(me.minText, me.formatDate(minValue)));
        }

        if (maxValue && time > clearTime(maxValue).getTime()) {
            errors.push(format(me.maxText, me.formatDate(maxValue)));
        }

        if (disabledDays) {
            day = value.getDay();

            for (; i < len; i++) {
                if (day === disabledDays[i]) {
                    errors.push(me.disabledDaysText);
                    break;
                }
            }
        }

        fvalue = me.formatDate(value);
        if (disabledDatesRE && disabledDatesRE.test(fvalue)) {
            errors.push(format(me.disabledDatesText, fvalue));
        }

        return errors;
    },

    rawToValue:function (rawValue) {
        return this.parseDate(rawValue) || rawValue || null;
    },

    valueToRaw:function (value) {
        return this.formatDate(this.parseDate(value));
    },

    /**
     * Sets the value of the date field.  You can pass a date object or any string that can be
     * parsed into a valid date, using <tt>{@link #format}</tt> as the date format, according
     * to the same rules as {@link Ext.Date#parse} (the default format used is <tt>"m/d/Y"</tt>).
     * <br />Usage:
     * <pre><code>
     //All of these calls set the same date value (May 4, 2006)

     //Pass a date object:
     var dt = new Date('5/4/2006');
     dateField.setValue(dt);

     //Pass a date string (default format):
     dateField.setValue('05/04/2006');

     //Pass a date string (custom format):
     dateField.format = 'Y-m-d';
     dateField.setValue('2006-05-04');
     </code></pre>
     * @param {String/Date} date The date or valid date string
     * @return {Ext.form.field.Date} this
     * @method setValue
     */

    /**
     * Attempts to parse a given string value using a given {@link Ext.Date#parse date format}.
     * @param {String} value The value to attempt to parse
     * @param {String} format A valid date format (see {@link Ext.Date#parse})
     * @return {Date} The parsed Date object, or null if the value could not be successfully parsed.
     */
    safeParse:function (value, format) {
        var me = this,
            utilDate = Ext.Date,
            parsedDate,
            result = null;

        if (utilDate.formatContainsHourInfo(format)) {
            // if parse format contains hour information, no DST adjustment is necessary
            result = utilDate.parse(value, format);
        } else {
            // set time to 12 noon, then clear the time
            parsedDate = utilDate.parse(value + ' ' + me.initTime, format + ' ' + me.initTimeFormat);
            if (parsedDate) {
                result = utilDate.clearTime(parsedDate);
            }
        }
        return result;
    },

    // @private
    getSubmitValue:function () {
        var me = this,
            format = me.submitFormat || me.format,
            value = me.getValue();

        return value ? Ext.Date.format(value, format) : "";
    },

    /**
     * @private
     */
    parseDate:function (value) {
        if (!value || Ext.isDate(value)) {
            return value;
        }

        var me = this,
            val = me.safeParse(value, me.format),
            altFormats = me.altFormats,
            altFormatsArray = me.altFormatsArray,
            i = 0,
            len;

        if (!val && altFormats) {
            altFormatsArray = altFormatsArray || altFormats.split('|');
            len = altFormatsArray.length;
            for (; i < len && !val; ++i) {
                val = me.safeParse(value, altFormatsArray[i]);
            }
        }
        return val;
    },

    // private
    formatDate:function (date) {
        return Ext.isDate(date) ? Ext.Date.dateFormat(date, this.format) : date;
    },

    createPicker:function () {
        var me = this,
            format = Ext.String.format;

        return Ext.create('Ext.picker.DateTime', {
            ownerCt:this.ownerCt,
            renderTo:document.body,
            floating:true,
            hidden:true,
            focusOnShow:true,
            minDate:me.minValue,
            maxDate:me.maxValue,
            disabledDatesRE:me.disabledDatesRE,
            disabledDatesText:me.disabledDatesText,
            disabledDays:me.disabledDays,
            disabledDaysText:me.disabledDaysText,
            format:me.format,
            showToday:me.showToday,
            startDay:me.startDay,
            minText:format(me.minText, me.formatDate(me.minValue)),
            maxText:format(me.maxText, me.formatDate(me.maxValue)),
            listeners:{
                scope:me,
                select:me.onSelect
            },
            keyNavConfig:{
                esc:function () {
                    me.collapse();
                }
            }
        });
    },

    onSelect:function (m, d) {
        this.setValue(d);
        this.fireEvent('select', this, d);
        this.collapse();
    },

    /**
     * @private
     * Sets the Date picker's value to match the current field value when expanding.
     */
    onExpand:function () {
        var me = this,
            value = me.getValue();
        me.picker.setValue(value instanceof Date ? value : new Date());
        if (value == null) {
            me.picker.hour.setValue(new Date().getHours());
            me.picker.minute.setValue(new Date().getMinutes());
            me.picker.second.setValue(new Date().getSeconds());
        } else {
            me.picker.hour.setValue(me.value.getHours());
            me.picker.minute.setValue(me.value.getMinutes());
            me.picker.second.setValue(me.value.getSeconds());
        }
    },

    /**
     * @private
     * Focuses the field when collapsing the Date picker.
     */
    onCollapse:function () {
        this.focus(false, 60);
    },

    // private
    beforeBlur:function () {
        var v = this.parseDate(this.getRawValue());
        if (v) {
            this.setValue(v);
        }
    }

    /**
     * @cfg {Boolean} grow @hide
     */
    /**
     * @cfg {Number} growMin @hide
     */
    /**
     * @cfg {Number} growMax @hide
     */
    /**
     * @hide
     * @method autoSize
     */
});
