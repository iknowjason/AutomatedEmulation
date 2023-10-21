## Terraform for scripts to bootstrap
locals {
  templatefiles = [
    
    {
      name = "${path.module}/files/windows/red.ps1.tpl"
      variables = {
        s3_bucket = "${aws_s3_bucket.staging.id}"
      }
    },
    
        {
      name = "${path.module}/files/windows/sysmon.ps1.tpl"
      variables = {
        s3_bucket     = "${aws_s3_bucket.staging.id}"
        region        = var.region
        sysmon_config = local.sysmon_config
        sysmon_zip    = local.sysmon_zip
        dc_ip         = "" 
        domain_join   = false 
      }
    },
    
    
    {
      name = "${path.module}/files/windows/prelude.ps1.tpl"
      variables = {
        s3_bucket    = "${aws_s3_bucket.staging.id}"
        caldera_port = var.caldera_port
        region       = var.region
        filename     = var.prelude_filename 
        bas_server   = aws_instance.bas_server.private_ip 
      }
},
    
  ]

  script_contents = [
    for t in local.templatefiles : templatefile(t.name, t.variables)
  ]

  script_output_generated = [
    for t in local.templatefiles : "${path.module}/output/windows/${replace(basename(t.name), ".tpl", "")}"
  ]

  # reference in the main user_data for each windows system
  script_files = [
    for tf in local.templatefiles :
    replace(basename(tf.name), ".tpl", "")
  ]
}

resource "local_file" "generated_scripts" {

  count = length(local.templatefiles)

  filename = local.script_output_generated[count.index]
  content  = local.script_contents[count.index]
}