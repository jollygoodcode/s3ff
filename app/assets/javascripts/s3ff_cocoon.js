$(document).on('cocoon:after-insert', function(e, insertedItem) {
  $(insertedItem).find(s3ff.selector).each(s3ff.init);
});
