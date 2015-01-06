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
          var placeholder = that.data('placeholder');
          var obj = that.data('s3ff') || [ {} ];
          $.each(obj, function() { this.placeholder = placeholder; });
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
              if (e.delegatedEvent.target.parentNode != wrap[0]) return e.preventDefault();
              $.observable(obj).refresh(data.files);
            },
            change: function(e, data) {
              $.observable(obj).refresh(data.files);
            },
            send: function(e, data) {
              $.each(obj, function() {
                if (data.files[0].unique_id == this.unique_id) {
                  this.progress_pct = "0%";
                  this.placeholder = placeholder;
                }
              });
              $.observable(obj).refresh(obj);
            },
            progress: function(e, data) {
              // $.observable(obj).refresh(obj); // progress bar animation doesn't work
              // :. adjust manually
              $.each(obj, function() {
                if (data.files[0].unique_id == this.unique_id) {
                  this.progress_pct = (parseInt(data.loaded / data.total * 100, 10)) + "%";
                  dom.find('#s3ff_progress-' + this.unique_id).show().find('.s3ff_bar').css({width: this.progress_pct}).text(this.name);
                }
              });
            },
            done: function(e, data) {
              var field_prefix = that.attr('name').replace(/(\]\[\]|\])$/, '');
              $.each(obj, function() {
                if (data.files[0].unique_id == this.unique_id) {
                  delete this.progress_pct;
                  this.fieldname = field_prefix + '_direct_url]' + (multi ? '[]' : '');
                  this.result = data.result;
                }
              });
              $.observable(obj).refresh(obj);
            },
            fail: function(e, data) {
              $.each(obj, function() {
                if (data.files[0].unique_id == this.unique_id) {
                  this.progress_pct = "80%";
                  this.failReason = data.failReason || data.textStatus || 'Failed!';
                }
              });
              $.observable(obj).refresh(obj);
            },
            add: function(e, data) {
              // beginning; disable submit
              wrap.parents("form").find("button,[type='submit']").each(function() {
                this.uploading = this.uploading || 0;
                $(this).attr({'disabled': (++this.uploading > 0)});
              });
              data.submit();
            },
            always: function(e, data) {
              // end; re-enable submit
              wrap.parents("form").find("button,[type='submit']").each(function() {
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

  $(document).bind('dragover', function (e) {
    var timeout = s3ff.dropZoneTimeout;
    if (! timeout) {
      $(document.body).addClass('s3ff_dragover');
    } else {
      clearTimeout(timeout);
    }
    s3ff.dropZoneTimeout = setTimeout(function () {
      $(document.body).removeClass('s3ff_dragover');
      s3ff.dropZoneTimeout = null;
    }, 100);
  });
});
