Delivered-To: ctgreybeard+mimetest@gmail.com
Received: by 10.194.242.5 with SMTP id wm5csp212246wjc;
        Thu, 4 Apr 2013 13:08:21 -0700 (PDT)
X-Received: by 10.68.230.193 with SMTP id ta1mr10608630pbc.103.1365106100785;
        Thu, 04 Apr 2013 13:08:20 -0700 (PDT)
Return-Path: <ctgreybeard@me.com>
Received: from nk11p03mm-asmtp001.mac.com (nk11p03mm-asmtp001.mac.com. [17.158.232.236])
        by mx.google.com with ESMTP id xr1si11881222pbc.249.2013.04.04.13.08.20;
        Thu, 04 Apr 2013 13:08:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of ctgreybeard@me.com designates 17.158.232.236 as permitted sender) client-ip=17.158.232.236;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ctgreybeard@me.com designates 17.158.232.236 as permitted sender) smtp.mail=ctgreybeard@me.com;
       dmarc=pass (p=NONE dis=none) d=me.com
Received: from [192.168.2.101]
 (c-24-63-153-88.hsd1.ct.comcast.net [24.63.153.88])
 by nk11p03mm-asmtp001.mac.com
 (Oracle Communications Messaging Server 7u4-26.01(7.0.4.26.0) 64bit (built Jul
 13 2012)) with ESMTPSA id <0MKQ00GXSYL7CE60@nk11p03mm-asmtp001.mac.com> for
 ctgreybeard+mimetest@gmail.com; Thu, 04 Apr 2013 20:07:57 +0000 (GMT)
X-Proofpoint-Virus-Version: vendor=fsecure
 engine=2.50.10432:5.10.8626,1.0.431,0.0.0000
 definitions=2013-04-04_07:2013-04-04,2013-04-04,1970-01-01 signatures=0
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 spamscore=0
 ipscore=0 suspectscore=1 phishscore=0 bulkscore=0 adultscore=0 classifier=spam
 adjust=0 reason=mlx scancount=1 engine=6.0.2-1302030000
 definitions=main-1304040191
From: ctgreybeard <ctgreybeard@me.com>
Content-type: multipart/alternative;
 boundary="Apple-Mail=_9099BA89-04A4-4600-AD18-57B1A5E9003D"
Subject: Testing MIME messages
Message-id: <70E5804D-DCBB-4917-8F8E-1B1181D1DCA1@me.com>
Date: Thu, 04 Apr 2013 16:07:55 -0400
To: ctgreybeard+mimetest@gmail.com
MIME-version: 1.0 (Mac OS X Mail 6.3 \(1503\))
X-Mailer: Apple Mail (2.1503)


--Apple-Mail=_9099BA89-04A4-4600-AD18-57B1A5E9003D
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=us-ascii

This is a test.  This is only a test. Had there been an actual message =
this would have been it.

Me


--Apple-Mail=_9099BA89-04A4-4600-AD18-57B1A5E9003D
Content-Type: multipart/mixed;
	boundary="Apple-Mail=_4A637328-6941-4E07-AEE7-C48C7F7BC9BF"


--Apple-Mail=_4A637328-6941-4E07-AEE7-C48C7F7BC9BF
Content-Transfer-Encoding: 7bit
Content-Type: text/html;
	charset=us-ascii

<html><head><meta http-equiv="Content-Type" content="text/html charset=us-ascii"></head><body style="word-wrap: break-word; -webkit-nbsp-mode: space; -webkit-line-break: after-white-space; "><b>This is a test.</b> &nbsp;This is only a test. Had there been an actual message this would have been it.<div><br></div><div>Me</div><div><br></div><div></div></body></html>
--Apple-Mail=_4A637328-6941-4E07-AEE7-C48C7F7BC9BF
Content-Disposition: attachment;
	filename=testfile.txt
Content-Type: text/plain;
	name="testfile.txt"
Content-Transfer-Encoding: 7bit

This is a text file to attach to a message as a test.

--Apple-Mail=_4A637328-6941-4E07-AEE7-C48C7F7BC9BF
Content-Transfer-Encoding: 7bit
Content-Type: text/html;
	charset=us-ascii

<html><head><meta http-equiv="Content-Type" content="text/html charset=us-ascii"></head><body style="word-wrap: break-word; -webkit-nbsp-mode: space; -webkit-line-break: after-white-space; "><div></div></body></html>
--Apple-Mail=_4A637328-6941-4E07-AEE7-C48C7F7BC9BF--

--Apple-Mail=_9099BA89-04A4-4600-AD18-57B1A5E9003D--
