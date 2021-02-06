import { Body, Controller, Get, Post } from '@nestjs/common';
import { AppService } from './app.service';
import { EnrollAdminDto, GreetingDto, RegisterUserDto } from './dto';

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) { }

  @Get()
  getHello(): string {
    return this.appService.getHello();
  }

  @Post('enroll-admin')
  async enrollAdmin(@Body() admin: EnrollAdminDto): Promise<any> {
    return await this.appService.enrollAdmin(admin);
  }

  @Post('register-user')
  async registerUser(@Body() user: RegisterUserDto): Promise<any> {
    return await this.appService.registerUser(user);
  }

  @Post('set-greeting')
  async setGreeting(@Body() greeting: GreetingDto): Promise<any> {
    return await this.appService.setGreeting(greeting);
  }

  @Post('get-greeting')
  async balanceOf(@Body() greeting: GreetingDto): Promise<any> {
    return await this.appService.getGreeting(greeting);
  }
  @Post('update-greeting')
  async updateGreeting(@Body() greeting: GreetingDto): Promise<any> {
    return await this.appService.setGreeting(greeting);
  }
}
