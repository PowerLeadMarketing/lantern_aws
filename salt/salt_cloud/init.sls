#XXX: some of these config files are actually specific to the use that
#cloudmaster makes of salt-cloud.  Move there.
/etc/salt/lantern.pem:
    file.managed:
        - source: salt://salt_cloud/{{ grains['aws_region'] }}.pem
        - user: root
        - group: root
        - mode: 600

/etc/salt/cloudmaster.id_rsa:
    file.managed:
        - source: salt://salt_cloud/cloudmaster.id_rsa
        - user: root
        - group: root
        - mode: 600

/etc/salt/cloud:
    file.managed:
        - source: salt://salt_cloud/cloud
        - template: jinja
        - user: root
        - group: root
        - mode: 600

/etc/salt/cloud.profiles:
    file.managed:
        - source: salt://salt_cloud/cloud.profiles
        - template: jinja
        - user: root
        - group: root
        - mode: 600

apache-libcloud:
    pip.installed:
        - upgrade: yes

salt-cloud:
    pip.installed:
        - name: salt-cloud==0.8.11
        - require:
              - pip: apache-libcloud

