import { Injectable } from '@nestjs/common';
import { EnrollAdminDto, GreetingDto, RegisterUserDto } from './dto';
import { enrollAdmin, invoke, query, registerUser } from './fabric';

@Injectable()
export class AppService {
  getHello(): string {
    return 'Explore Swagger UI at <a href="swagger">/swagger</a>';
  }

  async enrollAdmin(admin: EnrollAdminDto): Promise<any> {
    return await enrollAdmin(admin);
  }

  async registerUser(user: RegisterUserDto): Promise<any> {
    return await registerUser(user);
  }

  async getGreeting(greeting: GreetingDto): Promise<any> {
    return await query(greeting);
    // console.log(...greeting.args)

  }

  async setGreeting(greeting: GreetingDto): Promise<any> {
    return await invoke(greeting);
  }
}
