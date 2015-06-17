# 2015-06-15 (cc) <paul4hough@gmail.com>
#
hide=@
default:
	$(hide)echo 'targets: unittest'


realclean clean unittest:
	$(hide)$(MAKE) -C tests $@ hide=$(hide)
