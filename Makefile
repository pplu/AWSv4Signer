devel:
	cpanm -n -l local --installdeps .

build-test-suite:
	wget -O /tmp/aws-sig-v4-test-suite.zip  https://docs.aws.amazon.com/general/latest/gr/samples/aws-sig-v4-test-suite.zip
	unzip -d t/ /tmp/aws-sig-v4-test-suite.zip

test: devel
	PERL5LIB=local/lib/perl5 prove -I lib -v lib t/

dist:
	cpanm -n -l dzil-local Dist::Zilla
	PERL5LIB=dzil-local/lib/perl5 dzil-local/bin/dzil authordeps --missing | cpanm -n -l dzil-local
	#PERL5LIB=dzil-local/lib/perl5 dzil-local/bin/dzil smoke
	PERL5LIB=dzil-local/lib/perl5 dzil-local/bin/dzil build

