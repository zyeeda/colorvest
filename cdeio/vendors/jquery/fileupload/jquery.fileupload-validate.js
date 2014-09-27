/*
 * jQuery File Upload Validation Plugin 1.0.2
 * https://github.com/blueimp/jQuery-File-Upload
 *
 * Copyright 2013, Sebastian Tschan
 * https://blueimp.net
 *
 * Licensed under the MIT license:
 * http://www.opensource.org/licenses/MIT
 */

/*jslint nomen: true, unparam: true, regexp: true */
/*global define, window */

(function (factory) {
    'use strict';
    if (typeof define === 'function' && define.amd) {
        // Register as an anonymous AMD module:
        define([
            'jquery',
            './jquery.fileupload-process'
        ], factory);
    } else {
        // Browser globals:
        factory(
            window.jQuery
        );
    }
}(function ($) {
    'use strict';

    // Append to the default processQueue:
    $.blueimp.fileupload.prototype.options.processQueue.push(
        {
            action: 'validate',
            // Always trigger this action,
            // even if the previous action was rejected: 
            always: true,
            // Options taken from the global options map:
            acceptFileTypes: '@acceptFileTypes',
            maxFileSize: '@maxFileSize',
            minFileSize: '@minFileSize',
            maxNumberOfFiles: '@maxNumberOfFiles',
            disabled: '@disableValidation'
        }
    );

    // The File Upload Validation plugin extends the fileupload widget
    // with file validation functionality:
    $.widget('blueimp.fileupload', $.blueimp.fileupload, {

        options: {
            /*
            // The regular expression for allowed file types, matches
            // against either file type or file name:
            acceptFileTypes: /(\.|\/)(gif|jpe?g|png)$/i,
            // The maximum allowed file size in bytes:
            maxFileSize: 10000000, // 10 MB
            // The minimum allowed file size in bytes:
            minFileSize: undefined, // No minimal file size
            // The limit of files to be uploaded:
            maxNumberOfFiles: 10,
            */

            // Function returning the current number of files,
            // has to be overriden for maxNumberOfFiles validation:
            getNumberOfFiles: $.noop,

            maxFileSize: 100000000,
            minFileSize: undefined,
            maxNumberOfFiles: 100,

            // Error and info messages:
            messages: {
                maxNumberOfFiles: '文件个数超过限制',
                acceptFileTypes: '不支持的文件格式',
                maxFileSize: '文件大小超过限制',
                minFileSize: '文件大小超过限制'
            }
        },

        processActions: {

            validate: function (data, options) {
                if (options.disabled) {
                    return data;
                }
                var dfd = $.Deferred(),
                    settings = this.options,
                    file = data.files[data.index],
                    numberOfFiles = settings.getNumberOfFiles(),
                    reg, acceptFileTypesStr;

                if (numberOfFiles && $.type(options.maxNumberOfFiles) === 'number' &&
                        numberOfFiles + data.files.length > options.maxNumberOfFiles) {
                    file.error = settings.i18n('maxNumberOfFiles');
                    app.error('请不要上传多于100个的文件');
                } else if (options.acceptFileTypes &&
                        !(options.acceptFileTypes.test(file.type) ||
                        options.acceptFileTypes.test(file.name))) {
                    acceptFileTypesStr = options.acceptFileTypes.toString();
                    acceptFileTypesStr = acceptFileTypesStr.substring(acceptFileTypesStr.lastIndexOf('(') + 1, acceptFileTypesStr.lastIndexOf(')'));

                    reg = new RegExp("\\|","g");
                    acceptFileTypesStr = acceptFileTypesStr.replace(reg, '、');

                    file.error = settings.i18n('acceptFileTypes');
                    app.error('文件格式不支持，请参照以下格式：</br>' + acceptFileTypesStr);
                } else if (options.maxFileSize && file.size > options.maxFileSize) {
                    file.error = settings.i18n('maxFileSize');
                    app.error('请不要上传大于100MB的文件');
                } else if ($.type(file.size) === 'number' &&
                        file.size < options.minFileSize) {
                    file.error = settings.i18n('minFileSize');
                    app.error('请不要上传小于0KB的文件');
                } else {
                    delete file.error;
                }
                if (file.error || data.files.error) {
                    data.files.error = true;
                    dfd.rejectWith(this, [data]);
                } else {
                    dfd.resolveWith(this, [data]);
                }
                return dfd.promise();
            }

        }

    });

}));
