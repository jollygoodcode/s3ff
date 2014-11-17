//= require s3_file_field
//= require jsviews.min

$(function() {

  // adapted from http://www.html5rocks.com/en/tutorials/cors/
  function iCanHasCORSRequest() {
    var xhr = new XMLHttpRequest();
    return (("withCredentials" in xhr) || (typeof XDomainRequest != "undefined"));
  }
  if (! iCanHasCORSRequest()) return;

  $(document).on('page:change', function() {
    if (!window.s3ff) {
      window.s3ff = {
        selector: "[data-acl][data-aws-access-key-id]:not(.s3ff_enabled)",
        init: function () {
          if ($(this).hasClass('s3ff_enabled')) return;

          var that = $(this).addClass('s3ff_enabled');
          var multi = that.attr('multiple');
          var placeholder_url = that.data('placeholder-url') || that.data('placeholder_url');
          var obj = that.data('s3ff') || [ {} ];
          $.each(obj, function() { this.placeholder_url = placeholder_url; });
          var wrap = that.wrap('<div class="s3ff_fileinput_wrap"></div>').parent();
          var dom = $('<label class="s3ff_fileinput_label"></label>').attr('for', that.attr('id'));
          wrap.after(dom);
          var tmpl = $.templates($('#s3ff_template').html());
          tmpl.link(dom, obj);

          $(dom).on('click', '[data-dismiss]', function(event) {
            var unique_id = $(this).data('unique_id');
            $.each(obj, function() {
              if (unique_id == this.unique_id) {
                delete this.result;
                event.preventDefault();
                event.stopPropagation();
              }
            });
            $.observable(obj).refresh(obj);
          });

          var s3ff_handlers = {
            drop: function(e, data) {
              if (that[0] != e.originalEvent.target) return e.preventDefault();
              if (! multi) $.observable(obj).refresh(data.files);
            },
            change: function(e, data) {
              if (! multi) $.observable(obj).refresh(data.files);
            },
            send: function(e, data) {
              $.each(obj, function() {
                if (data.files[0].unique_id == this.unique_id) {
                  dom.find('.s3ff_bar').parent().show();
                  this.placeholder_url = placeholder_url;
                }
              });
              // $.observable(obj).refresh(obj); // progress bar animation doesn't work
            },
            progress: function(e, data) {
              $.each(obj, function() {
                if (data.files[0].unique_id == this.unique_id) {
                  this.progress = (parseInt(data.loaded / data.total * 100, 10)) + "%";
                  dom.find('.s3ff_bar').css({width: this.progress}).text(this.progress);
                }
              });
              // $.observable(obj).refresh(obj); // progress bar animation doesn't work
            },
            done: function(e, data) {
              var field_prefix = that.attr('name').replace(/\]$/, '');
              $.each(obj, function() {
                if (data.files[0].unique_id == this.unique_id) {
                  delete this.progress;
                  this.fieldname = field_prefix + '_direct_url';
                  this.result = data.result;
                }
              });
              $.observable(obj).refresh(obj);
            },
            fail: function(e, data) {
              $.each(obj, function() {
                if (data.files[0].unique_id == this.unique_id) {
                  this.progress_pct = "80%";
                  this.progress_style = "width:" + this.progress_pct;
                  this.failReason = data.failReason || data.textStatus || 'Failed!';
                }
              });
              $.observable(obj).refresh(obj);
            },
            add: function(e, data) {
              // beginning; disable submit
              wrap.parents("form").find("[type='submit']").each(function() {
                this.uploading = this.uploading || 0;
                $(this).attr({'disabled': (++this.uploading > 0)});
              });
              data.submit();
            },
            always: function(e, data) {
              // end; re-enable submit
              wrap.parents("form").find("[type='submit']").each(function() {
                this.uploading = this.uploading || 0;
                $(this).attr({'disabled': (--this.uploading > 0)});
              });
            }
          };

          that.S3FileField(s3ff_handlers);
        }
      }
    }
    $(s3ff.selector).each(s3ff.init);
    $(document).on("mouseenter mousedown touchstart", s3ff.selector, s3ff.init);
  });
});
