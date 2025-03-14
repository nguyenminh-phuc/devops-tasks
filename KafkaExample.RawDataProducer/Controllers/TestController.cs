﻿using Microsoft.AspNetCore.Mvc;

namespace KafkaExample.RawDataProducer.Controllers;

[Route("[controller]")]
[ApiController]
public sealed class TestController : ControllerBase
{
    public Task<ActionResult> Index() => Task.FromResult<ActionResult>(Ok());
}
