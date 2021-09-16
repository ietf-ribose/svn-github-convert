# Makefile for postconfirm conversion using reposurgeon
#
# Steps to using this:
# 1. Make sure reposurgeon and repotool are on your $PATH.
# 2. (Skip this step if you're starting from a stream file.) For svn, set
#    REMOTE_URL to point at the remote repository you want to convert;
#    you can use either an svn: URL or an rsync: URL for this.
#    If the repository is already in a DVCS such as hg or git,
#    set REMOTE_URL to either the normal cloning URL (starting with hg://,
#    git://, etc.) or to the path of a local clone.
# 3. For cvs, set CVS_HOST to the repo hostname and CVS_MODULE to the module,
#    then uncomment the line that builds REMOTE_URL
#    Note: for CVS hosts other than Sourceforge or Savannah you will need to
#    include the path to the CVS modules directory after the hostname.
# 4. Set any required read options, such as --user-ignores or --nobranch,
#    by setting READ_OPTIONS.
# 5. Optionally, replace the default value of DUMPFILTER with a
#    command or pipeline that actually filters the dump rather than
#    just copying it through.  The most usual reason to do this is
#    that your Subversion repository is multiproject and you want to
#    strip out one subtree for conversion with repocutter sift and pop
#    commands.  Note that if you ever did copies across project
#    subtrees this simple stripout will not work - you are in deep
#    trouble and should find an expert to advise you
# 6. Run 'make stubmap' to create a stub author map.
# 7. Run 'make' to build a converted repository.
#
# For a production-quality conversion you will need to edit the map
# file and the lift script.  During the process you can set EXTRAS to
# name extra metadata such as a comments message-box.
#
# Afterwards, you can use the *compare productions to check your work.
#

EXTRAS =
REMOTE_URL = svn://svn.debian.org/postconfirm
#REMOTE_URL = https://postconfirm.googlecode.com/svn/
CVS_HOST = postconfirm.cvs.sourceforge.net
#CVS_HOST = cvs.savannah.gnu.org
CVS_MODULE = postconfirm
#REMOTE_URL = cvs://$(CVS_HOST)/postconfirm\#$(CVS_MODULE)
READ_OPTIONS = --branchify=trunk:branch/*:personal/*:tags/*:*
DUMPFILTER = cat
VERBOSITY = "set progress"
REPOSURGEON = reposurgeon
LOGFILE = conversion.log

# Set and uncomment these if remote access tio Subversion needs credentials.
#export RUSERNAME=
#export RPASSWORD=

# Configuration ends here

.PHONY: local-clobber remote-clobber gitk gc compare clean dist stubmap

default: postconfirm-git

# Build the repository from the stream dump
postconfirm-git: postconfirm.svn postconfirm.opts postconfirm.lift postconfirm.map $(EXTRAS)
	$(REPOSURGEON) $(VERBOSITY) 'logfile $(LOGFILE)' 'script postconfirm.opts' "read $(READ_OPTIONS) <postconfirm.svn" 'authors read <postconfirm.map' 'sourcetype svn' 'prefer git' 'script postconfirm.lift' 'legacy write >postconfirm.fo' 'rebuild postconfirm-git'

# Build a stream dump from the local mirror
postconfirm.svn: postconfirm-mirror
	(cd postconfirm-mirror/ >/dev/null; repotool export) | $(DUMPFILTER) >postconfirm.svn

# Build a local mirror of the remote repository
postconfirm-mirror:
	repotool mirror $(REMOTE_URL) postconfirm-mirror

# Make a local checkout of the source mirror for inspection
%-checkout: %-mirror
	cd %-mirror >/dev/null; repotool checkout $(PWD)/%-checkout

# Force rebuild of stream from the local mirror on the next make
local-clobber: clean
	rm -fr postconfirm.fi postconfirm-git

# Force full rebuild from the remote repo on the next make.
remote-clobber: local-clobber
	rm -fr postconfirm.svn *-mirror *-checkout

# Get the (empty) state of the author mapping from the first-stage stream
stubmap: postconfirm.svn
	$(REPOSURGEON) $(VERBOSITY) "read $(READ_OPTIONS) <postconfirm.svn" 'authors write >postconfirm.map'

# Compare the histories of the unconverted and converted repositories at head
# and all tags.
headcompare: postconfirm-mirror postconfirm-git
	repotool compare postconfirm-mirror postconfirm-git
tagscompare: postconfirm-mirror postconfirm-git
	repotool compare-tags postconfirm-mirror postconfirm-git
branchescompare: postconfirm-mirror postconfirm-git
	repotool compare-branches postconfirm-mirror postconfirm-git
allcompare: postconfirm-mirror postconfirm-git
	repotool compare-all postconfirm-mirror postconfirm-git

# General cleanup and utility
clean:
	rm -fr *~ .rs* postconfirm-conversion.tar.gz *.svn *.fi *.fo

# Bundle up the conversion metadata for shipping
SOURCES = Makefile postconfirm.opts postconfirm.lift postconfirm.map $(EXTRAS)
postconfirm-conversion.tar.gz: $(SOURCES)
	tar --dereference --transform 's:^:postconfirm-conversion/:' -czvf postconfirm-conversion.tar.gz $(SOURCES)

dist: postconfirm-conversion.tar.gz

#
# The following productions are git-specific
#

# Browse the generated git repository
gitk: postconfirm-git
	cd postconfirm-git; gitk --all

# Run a garbage-collect on the generated git repository.  Import doesn't.
# This repack call is the active part of gc --aggressive.  This call is
# tuned for very large repositories.
gc: postconfirm-git
	cd postconfirm-git; time git -c pack.threads=1 repack -AdF --window=1250 --depth=250
