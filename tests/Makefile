# 2015-06-15 (cc) <paul4hough@gmail.com>
#
hide=@

roles/pahoughton.bacula.sd:
	$(hide)mkdir roles
	$(hide)ln -s ../.. $@
	$(hide)test -f $@/tasks/main.yml

unittest: roles/pahoughton.bacula.sd
	$(hide)ansible-playbook -i unittest.inv --syntax-check unittest.yml
	$(hide)bash unittest.bash
